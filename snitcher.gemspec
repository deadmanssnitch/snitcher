# encoding: UTF-8

Gem::Specification.new do |spec|
  spec.name    = "snitcher"
  spec.version = "0.1.0"

  spec.author   = "Chris Gaffney"
  spec.email    = "gaffneyc@gmail.com"
  spec.homepage = "https://github.com/gaffneyc/snitcher"
  spec.summary  = "Simple API client for deadmanssnitch.com"
  spec.license  = "MIT"

  spec.files       = `git ls-files`.split($/)
  spec.executables = spec.files.grep(/^bin/) { |f| File.basename(f) }
  spec.test_files  = spec.files.grep(/^spec/)

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
end
