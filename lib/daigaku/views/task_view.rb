require 'wisper'
require 'os'

module Daigaku
  module Views
    class TaskView
      include Views
      include Wisper::Publisher

      TOP_BAR_TEXT = [
        'Scroll with *UP KEY* and *DOWN KEY*',
        'Open solution file with *o*',
        'Verify solution with *v*',
        'Clear validation with *c*',
        'Exit with *ESC*'
      ].join('  |  ').freeze

      def initialize
        @lines = []
        @top   = nil
      end

      def enter(course, chapter, unit)
        @course  = course
        @chapter = chapter
        @unit    = unit

        @test_result_lines = nil
        @lines             = @unit.task.markdown.lines
        @top_bar_height    = 4
        @head_height       = 2

        initialize_window(@lines.count + @top_bar_height + @head_height)
      end

      private

      def print_head(window)
        window.setpos(0, 1)
        window.clear_line

        text = "*#{@course.title}* > *#{@chapter.title}* > *#{@unit.title}*:"
        window.print_markdown(text)

        window.setpos(1, 1)
        window.clear_line
      end

      def show(window)
        window.scrollok(true)
        draw(window)
        interact_with(window)
      end

      def draw(window)
        @top = 0
        window.attrset(A_NORMAL)
        print_head(window)

        @lines.each_with_index do |line, index|
          window.setpos(index + 2, 1)
          print_line(window, line, index)
        end

        window.setpos(0, 1)
        window.refresh
      end

      def scroll_up(window)
        return unless @top > 0

        window.scrl(-1)
        print_head(window)

        @top -= 1
        line = @lines[@top]

        return unless line
        window.setpos(2, 1)
        print_line(window, line, @top)
      end

      def scroll_down(window)
        if @top + Curses.lines <= @lines.count + @top_bar_height + @head_height
          window.scrl(1)
          print_head(window)

          @top += 1
          line = @lines[@top + window.maxy - 1]
          window.setpos(window.maxy - 1, 1)

          if line
            print_line(window, line, @top)
          else
            window.clear_line
          end

          return true
        else
          return false
        end
      end

      def print_line(window, line, index)
        if @test_result_lines && index.between?(0, @test_result_lines.count + 1)
          if @unit.mastered?
            window.green(line, A_STANDOUT, full_line: true)
          else
            example_index = example_index(@example_heights, index)

            if @examples[example_index].passed?
              window.green(line, A_STANDOUT, full_line: true)
            else
              window.red(line, A_STANDOUT, full_line: true)
            end
          end
        else
          window.print_markdown(line.strip)
        end
      end

      def interact_with(window)
        while char = window.getch
          scrollable = true

          case char
          when 'v' # verify
            print_test_results
            return
          when 'c' # clear
            reset_screen
            return
          when 'o' # open solution file
            open_editor(@unit.solution.path)
          when Curses::KEY_DOWN, Curses::KEY_CTRL_N
            scrollable = scroll_down(window)
          when Curses::KEY_UP, Curses::KEY_CTRL_P
            scrollable = scroll_up(window)
          when Curses::KEY_NPAGE, '?\s' # white space
            0.upto(window.maxy - 2) do |n|
              scrolled = scroll_down(window)

              unless scrolled
                scrollable = false if n == 0
                break
              end
            end
          when Curses::KEY_PPAGE
            0.upto(window.maxy - 2) do |n|
              scrolled = scroll_up(window)

              unless scrolled
                scrollable = false if n == 0
                break
              end
            end
          when Curses::KEY_LEFT, Curses::KEY_CTRL_T
            while scroll_up(window)
            end
          when Curses::KEY_RIGHT, Curses::KEY_CTRL_B
            while scroll_down(window)
            end
          when Curses::KEY_BACKSPACE
            broadcast(:reenter, @course, @chapter, @unit)
            return
          when 27 # ESC
            exit
          end

          Curses.beep unless scrollable
          window.setpos(0, 1)
          window.refresh
        end
      end

      def open_editor(file_path)
        if OS.windows?
          system "start '' '#{file_path}'"
        elsif OS.mac?
          system "open '#{file_path}'"
        elsif OS.linux?
          system "xdg-open '#{file_path}'"
        end
      end

      def print_test_results
        result             = @unit.solution.verify!
        @test_result_lines = test_result_lines(result)

        if result.passed?
          code_lines = @unit.reference_solution.code_lines

          unless code_lines.empty?
            code_lines.map! { |line| "  #{line}" }
            code_lines.unshift('', 'Reference code:', '')
          end

          @test_result_lines += code_lines
        end

        @lines = [''] + @test_result_lines + ['', ''] + @unit.task.markdown.lines
        @examples = result.examples

        @example_heights = @examples.reduce({}) do |hash, example|
          start = hash.values.reduce(0) { |sum, results| sum + results.count }
          range = (start..(start + example.message.split("\n").count) + 2)
          hash[hash.keys.count] = range
          hash
        end

        lines_count = @lines.count + @top_bar_height + @head_height
        height      = [lines_count, Curses.lines].max

        initialize_window(height)
      end

      def test_result_lines(result)
        lines  = result.summary_lines
        lines += code_error_lines(@unit.solution.code) unless result.passed?
        lines
      end

      def code_error_lines(code)
        begin
          eval(code)
        rescue StandardError => e
          return e.inspect.gsub(/(\A.*#<|>.*$)/, '').lines.map(&:rstrip)
        end

        []
      end

      def reset_screen
        @test_result_lines = nil
        @lines             = @unit.task.markdown.lines
        lines_count        = @lines.count + @top_bar_height + @head_height
        height             = [lines_count, Curses.lines].max

        initialize_window(height)
      end

      def initialize_window(height)
        @window = default_window(height)

        top_bar = TopBar.new(@window, TOP_BAR_TEXT)
        show sub_window_below_top_bar(@window, top_bar)
      end

      def example_index(heights, index)
        heights.values.index { |range| range.include?(index) }.to_i
      end
    end
  end
end
