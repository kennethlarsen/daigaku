module PathHelpers
  LOCAL_DIR = '.daigaku'
  CONFIGURATION_FILE = 'daigaku.settings'
  COURSES = 'courses'
  SOLUTIONS = 'solutions'
  TEMP_PATH = File.expand_path("../../../../tmp/", __FILE__)
  COURSE_DIR_NAMES = ['Course_A', 'Course_B']
  CHAPTER_DIR_NAMES = ['Chapter-1', 'Chapter-2']
  UNIT_DIR_NAMES = ['unit-1', 'unit-2']
  TASK_NAME = 'task.md'
  REFERENCE_SOLUTION_NAME = 'solution.rb'
  TEST_NAME = 'solution_spec.rb'

  def temp_basepath
    TEMP_PATH
  end

  def test_basepath
    File.join(TEMP_PATH, 'test')
  end

  def course_dir_names
    COURSE_DIR_NAMES
  end

  def chapter_dir_names
    CHAPTER_DIR_NAMES
  end

  def unit_dir_names
    UNIT_DIR_NAMES
  end

  def task_name
    TASK_NAME
  end

  def reference_solution_name
    REFERENCE_SOLUTION_NAME
  end

  def test_name
    TEST_NAME
  end

  def courses_basepath
    File.join(test_basepath, COURSES)
  end

  def solutions_basepath
    File.join(test_basepath, SOLUTIONS)
  end

  def course_dirs
    course_dir_names.map do |dir|
      File.join(courses_basepath, dir)
    end
  end

  def chapter_dirs(course_name)
    chapter_dir_names.map do |chapter|
      File.join(courses_basepath, course_name, chapter)
    end
  end

  def unit_dirs(course_name)
    chapter_dir_names.map do |chapter|
      unit_dir_names.map do |unit|
        File.join(courses_basepath, course_name, chapter, unit)
      end
    end
  end

  def all_unit_dirs
    dirs = course_dirs.map do |course_dir|
      chapter_dir_names.map do |chapter_name|
        unit_dir_names.map do |unit_name|
          File.join(course_dir, chapter_name, unit_name)
        end
      end
    end

    dirs.flatten
  end

  def all_solution_file_paths
    all_unit_dirs.map do |unit_dir|
      underscored_unit_dir =  File.basename(unit_dir).gsub(/(\_+|\-+|\.+)/, '_')
      file_name = underscored_unit_dir + Daigaku::Generator::SOLUTION_SUFFIX
      unit_path = File.join(solutions_basepath, unit_dir.split('/')[-3..-1])

      File.join(File.dirname(unit_path), file_name)
    end
  end

  def all_test_file_paths
    all_unit_dirs.map do |unit_dir|
      File.join(unit_dir, test_name)
    end
  end

  def course_titles
    gsub_underscores(course_dir_names)
  end

  def chapter_titles
    gsub_underscores(chapter_dir_names)
  end

  def unit_titles
    gsub_underscores(unit_dir_names)
  end

  def gsub_underscores(names)
    names.map { |unit| unit.gsub(/\_+/, ' ') }
  end

  def local_courses_path
    File.expand_path(File.join('~', LOCAL_DIR, COURSES))
  end

  def local_configuration_file
    File.expand_path(File.join('~', LOCAL_DIR, CONFIGURATION_FILE))
  end
end
