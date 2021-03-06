require 'rspec'
require 'webmock/rspec'

def require_files_from(paths = [])
  paths.each do |path|
    files = Dir[File.join(File.expand_path("#{path}*.rb", __FILE__))].sort
    files.each { |file| require file }
  end
end

RSpec.configure do |config|
  config.color = true

  require File.expand_path('../../lib/daigaku', __FILE__)
  require_files_from ['../support/**/']

  config.include TestHelpers

  config.before(:each, type: :view) { mock_default_window }

  config.before(:all) do
    prepare_courses
    use_test_storage_file
  end

  config.after(:all) { cleanup_temp_data }
end
