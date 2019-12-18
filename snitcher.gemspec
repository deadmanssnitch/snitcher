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

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
