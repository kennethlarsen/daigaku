require 'spec_helper'

describe Daigaku::Generator do
  subject { Daigaku::Generator.new }

  before do
    Daigaku.config.instance_variable_set(:@storage_file, local_storage_file)
  end

  it { is_expected.to respond_to :scaffold }
  it { is_expected.to respond_to :prepare }

  describe '#scaffold' do
    it 'creates blank solution files for all available units' do
      subject.scaffold(courses_basepath, solutions_basepath)

      all_solution_file_paths.each do |file_path|
        expect(File.exist?(file_path)).to be true
      end
    end
  end

  describe '#prepare' do
    context 'with an existing solutions_path' do
      before do
        Daigaku.configure do |config|
          config.solutions_path = solutions_basepath
          config.courses_path   = local_courses_path
        end

        subject.prepare
      end

      it 'generates a "<basepath>/.daigaku/daigaku.db.yml" file' do
        expect(File.exist?(local_storage_file)).to be true
      end

      it 'generates a "<basepath>/.daigaku/courses" folder' do
        expect(Dir.exist?(local_courses_path)).to be true
      end

      it 'saves the current config info' do
        expect(File.exist?(local_storage_file)).to be true
        expect(QuickStore.store.courses_path).to eq local_courses_path
        expect(QuickStore.store.solutions_path).to eq solutions_basepath
      end
    end

    context 'with a missing solutions_path' do
      before do
        remove_directory(solutions_basepath)

        base_path       = File.dirname(Daigaku.config.courses_path)
        @solutions_path = File.join(base_path, 'solutions')

        Daigaku.config.instance_variable_set(:@solutions_path, nil)
        Daigaku.configure { |config| config.courses_path = local_courses_path }

        subject.prepare
      end

      it 'generates a "solutions" path on the base directory as the courses' do
        expect(Dir.exist?(@solutions_path)).to be_truthy
      end

      it 'generates a "<basepath>/.daigaku/daigaku.db.yml" file' do
        expect(File.exist?(local_storage_file)).to be_truthy
      end

      it 'generates a "<basepath>/.daigaku/courses" folder' do
        expect(Dir.exist?(local_courses_path)).to be_truthy
      end

      it 'saves the current config info' do
        expect(File.exist?(local_storage_file)).to be_truthy
        expect(QuickStore.store.courses_path).to eq local_courses_path
        expect(QuickStore.store.solutions_path).to eq @solutions_path
      end
    end
  end
end
