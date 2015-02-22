require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
 
task :default => :spec

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) {|t|
  t.rspec_opts = '-I src -I spec -fdoc'
}

desc 'Run RuboCop on the src directory'
RuboCop::RakeTask.new(:lint) do |task|
  task.patterns = [
    'src/**/*.rb', 
    'spec/**/*.rb', 
    'config/**/*.rb'
  ]
  task.formatters = ['html']
  task.options = [
    '--auto-correct', 
    '-o', './lint/rubocop.html', 
    '-c', 'config/rubocop.yml'
  ]
  task.fail_on_error = false
end