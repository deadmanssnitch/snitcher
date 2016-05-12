require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "yard-ghpages"
Yard::GHPages::Tasks.install_tasks

task default: :spec
