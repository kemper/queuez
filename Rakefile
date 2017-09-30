require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require "bundler/gem_helper"
Bundler::GemHelper.install_tasks
