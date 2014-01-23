# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yaoc/version'

Gem::Specification.new do |spec|
  spec.name          = "yaoc"
  spec.version       = Yaoc::VERSION
  spec.authors       = ["Dieter Späth"]
  spec.email         = ["shad0wrunner@gmx.de"]
  spec.summary       = %q{Yet another object converter}
  spec.description   = %q{Yet another object converter}
  spec.homepage      = "https://github.com/slowjack2k/yaoc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency "abstract_type", '~> 0.0.7'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec", "2.99.0.beta1"
  # show nicely how many specs have to be run
  spec.add_development_dependency "fuubar"
  # extended console
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'pry-remote'

  # automatic execute tasks on file changes
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'rb-fsevent'

  # https://github.com/pry/pry-stack_explorer
  spec.add_development_dependency 'pry-stack_explorer'
  # https://github.com/nixme/pry-debugger
  spec.add_development_dependency 'pry-debugger'

  # https://github.com/dkubb/equalizer
  spec.add_development_dependency 'equalizer'
end
