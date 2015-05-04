lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daigaku/version'

Gem::Specification.new do |spec|
  spec.name          = "daigaku"
  spec.version       = Daigaku::VERSION
  spec.required_ruby_version = '~> 2.0'
  spec.authors       = ["Paul Götze"]
  spec.email         = ["paul.christoph.goetze@gmail.com"]
  spec.summary       = %q{Learning Ruby on the command line.}
  spec.description   = %q{Daigaku is the Japanese word for university. With Daigaku you can interactively learn the Ruby programming language using the command line.}
  spec.homepage      = "https://github.com/daigaku-ruby/daigaku"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  if RUBY_VERSION >= '2.1'
    spec.add_runtime_dependency "curses", ">= 1.0", "< 2.0"
  end

  spec.add_runtime_dependency "activesupport", ">= 4.0", "< 5.0"
  spec.add_runtime_dependency "rspec", ">= 3.0", "< 4.0"
  spec.add_runtime_dependency "thor", "~> 0.19.1"
  spec.add_runtime_dependency "os", "~> 0.9.6"
  spec.add_runtime_dependency "colorize", "~> 0.7.5"
  spec.add_runtime_dependency "rubyzip", ">= 1.0", "< 2.0"
  spec.add_runtime_dependency "wisper", ">= 2.0.0.rc1", "< 3.0"
  spec.add_runtime_dependency "quick_store", "~> 0.1.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "webmock", "~> 1.20.4"
  spec.add_development_dependency "guard-rspec", "~> 4.5.0"
end
