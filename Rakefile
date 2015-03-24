require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task :default   => [:spec,:rest_spec,:lint]
task :rest_spec => [:rest_spec_json, :rest_spec_messagepack]

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) {|t|
  t.rspec_opts = '-I src -I spec -fdoc'
}

desc "Run all specs in rest_spec directory using json transport"
RSpec::Core::RakeTask.new(:rest_spec_json) {|t|
  t.rspec_opts = '-I src -I spec -I rest_spec -fdoc'
  t.pattern    = 'rest_spec/use_json_transport.rb'
}
desc "Run all specs in rest_spec directory using messagepack transport"
RSpec::Core::RakeTask.new(:rest_spec_messagepack) {|t|
  t.rspec_opts = '-I src -I spec -I rest_spec -fdoc'
  t.pattern    = 'rest_spec/use_messagepack_transport.rb'
}

desc 'Run RuboCop on the src/spec directory'
task :lint => [:lint_src, :lint_spec]

RuboCop::RakeTask.new(:lint_src) do |task|
  init_rubocop_task(task, ['src'])
end
RuboCop::RakeTask.new(:lint_spec) do |task|
  init_rubocop_task(task, ['spec','rest_spec'])
end

def init_rubocop_task(task,src_dirs)
  task.patterns = src_dirs.map do |dir|
    "#{dir}/**/*.rb"
  end + ['config/**/*.rb']
  task.formatters = ['html']
  task.options = [
    '--auto-correct',
    '-o', File.join(build_dir, "lint", "rubocop_#{src_dirs[0]}.html"),
    '-c', "config/rubocop/#{src_dirs[0]}.yml"
  ]
  task.fail_on_error = false
end

def build_dir
  ENV['CIRCLE_ARTIFACTS'] || 'build'
end
