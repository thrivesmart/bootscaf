# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bootscaf/version'

Gem::Specification.new do |spec|
  spec.name          = "bootscaf"
  spec.version       = Bootscaf::VERSION
  spec.authors       = ["Matthew Moore"]
  spec.email         = ["hello@thrivesmart.com"]
  spec.summary       = %q{Overwrites a Ruby on Rails scaffold generation and makes it look great.}
  spec.description   = %q{Really great.}
  spec.homepage      = "https://github.com/thrivesmart/bootscaf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "thor"
  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
end
