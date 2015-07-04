# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baabedo/version'

Gem::Specification.new do |spec|
  spec.name          = "baabedo"
  spec.version       = Baabedo::VERSION
  spec.authors       = ["Maximilian Goisser"]
  spec.email         = ["maximilian.goiser@baabedo.com"]
  spec.summary       = %q{Ruby bindings for the Baabedo API}
  spec.description   = %q{Baabedo is an easy to use price optimization AI. See https://baabedo.com}
  spec.homepage      = "https://baabedo.com/api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('rest-client', '~> 1.4')
  spec.add_dependency('json', '~> 1.8.1')

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "guard-rspec", "~> 4.5"
end
