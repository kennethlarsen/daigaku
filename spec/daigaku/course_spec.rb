require 'spec_helper'

describe Daigaku::Course do
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :chapters }
  it { is_expected.to respond_to :path }
  it { is_expected.to respond_to :author }
  it { is_expected.to respond_to :link }

  it { is_expected.to respond_to :mastered? }
  it { is_expected.to respond_to :started? }

  before :all do
    prepare_courses
  end

  after :all do
    cleanup_courses
  end

  subject { Daigaku::Course.new(course_dirs.first) }

  it "has the prescribed title" do
    expect(subject.title).to eq course_titles.first
  end

  it "has the prescribed path" do
    expect(subject.path).to eq course_dirs.first
  end

  it "is not started by default" do
    expect(subject.started?).to be_falsey
  end

  it "is not mastered by default" do
    expect(subject.mastered?).to be_falsey
  end

  describe "#chapters" do
    it "loads the prescribed number of chapters" do
      expect(subject.chapters.count).to eq available_chapters(course_dirs.first).count
    end

    it "lazy-loads the chapters" do
      expect(subject.instance_variable_get(:@chaptera)).to be_nil
      subject.chapters
      expect(subject.instance_variable_get(:@chapters)).not_to be_nil
    end
  end
end