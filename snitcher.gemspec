# encoding: UTF-8

$:.unshift File.expand_path("../lib", __FILE__)
require "snitcher/version"

Gem::Specification.new do |spec|
  spec.name    = "snitcher"
  spec.version = Snitcher::VERSION

  spec.author   = "Collective Idea"
  spec.email    = "hi@deadmanssnitch.com"
  spec.homepage = "https://github.com/deadmanssnitch/snitcher"
  spec.summary  = "Simple API client for deadmanssnitch.com"
  spec.license  = "MIT"

  spec.files       = `git ls-files`.split($/)
  spec.executables = spec.files.grep(/^bin/) { |f| File.basename(f) }
  spec.test_files  = spec.files.grep(/^spec/)

  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
end
