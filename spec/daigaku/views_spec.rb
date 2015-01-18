require 'spec_helper'

describe Daigaku::Views do

  subject do
    class Test
      include Daigaku::Views
    end

    Test.new
  end

  [:default_window, :menu_bar].each do |method|
    it "has a private method #{method}" do
      expect(subject.private_methods.include?(method)).to be_truthy
    end
  end
end