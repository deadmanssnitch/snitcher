# encoding: UTF-8
Gem::Specification.new do |s|
  s.name               = "snitcher"
  s.homepage           = "https://github.com/gaffneyc/snitcher"
  s.summary            = "Simple API client for deadmanssnitch.com"
  s.require_path       = "lib"
  s.authors            = ["Chris Gaffney"]
  s.email              = ["gaffneyc@gmail.com"]
  s.version            = "0.1.0"
  s.platform           = Gem::Platform::RUBY
  s.files              = Dir.glob("lib/**/*") + %w[LICENSE README.md]
end
