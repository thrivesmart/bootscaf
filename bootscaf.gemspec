# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bootscaf/version'

Gem::Specification.new do |spec|
  spec.name          = "bootscaf"
  spec.version       = Bootscaf::VERSION
  spec.authors       = ["Matthew Moore"]
  spec.email         = ["hello@thrivesmart.com"]
  spec.summary       = %q{I absolutely love the rails g scaffold command for new projects. But I can’t stand that there’s no easy way to output good-lookin’ bootstrap layouts by default. I also haven’t found a twitter bootstap gem that can go back to old scaffolds and just re-jigger them at any time. So we created Bootscaf, a gem that lets you run a command that seds all your scaffold view files to use bootstrap friendly classes.  Best of all, it’s open-source.}
  spec.description   = %q{Easily turn your rails generated scaffolds into fully bootstrappified views.}
  spec.homepage      = "https://github.com/thrivesmart/bootscaf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "thor"
  spec.add_dependency "rails"
  
  spec.add_development_dependency "rspec"
end
