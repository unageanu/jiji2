require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
 
task :default => [:spec,:lint]

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) {|t|
  t.rspec_opts = '-I src -I spec -fdoc'
}

desc 'Run RuboCop on the src/spec directory'
task :lint => [:lint_src, :lint_spec]

RuboCop::RakeTask.new(:lint_src) do |task|
  init_rubocop_task(task, 'src')
end
RuboCop::RakeTask.new(:lint_spec) do |task|
  init_rubocop_task(task, 'spec')
end

def init_rubocop_task(task,src_dir)
  task.patterns = [
    "#{src_dir}/**/*.rb", 
    'config/**/*.rb'
  ]
  task.formatters = ['html']
  task.options = [
    '--auto-correct', 
    '-o', "./lint/rubocop_#{src_dir}.html", 
    '-c', "config/rubocop/#{src_dir}.yml"
  ]
  task.fail_on_error = false
end
