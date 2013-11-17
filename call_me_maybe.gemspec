# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'call_me_maybe/version'

Gem::Specification.new do |spec|
  spec.name          = "call_me_maybe"
  spec.version       = CallMeMaybe::VERSION
  spec.authors       = ["Kelly Becker"]
  spec.email         = ["kellylsbkr@gmail.com"]
  spec.description   = %q{Event handler and listener for Ruby}
  spec.summary       = %q{Listens and captures event comings from objects}
  spec.homepage      = "http://kellybecker.me"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

  spec.add_development_dependency "activesupport", ">= 3.2.12"
end
