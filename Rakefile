require 'rake'
require 'rubygems/version'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'rdoc/task'

task :default   => [:spec,:rest_spec,:rpc_spec,:python_spec,:python_rpc_spec,:lint]
task :rest_spec => [:rest_spec_json, :rest_spec_messagepack]

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) {|t|
  t.rspec_opts = '-I src -I spec -I sample_agents/src -I sample_agents/spec -I rpc/ruby -fdoc'
}

desc "Run all specs in rest_spec directory using json transport"
RSpec::Core::RakeTask.new(:rest_spec_json) {|t|
  t.rspec_opts = '-I src -I spec -I rest_spec -I rpc/ruby -fdoc'
  t.pattern    = 'rest_spec/use_json_transport.rb'
}
desc "Run all specs in rest_spec directory using messagepack transport"
RSpec::Core::RakeTask.new(:rest_spec_messagepack) {|t|
  t.rspec_opts = '-I src -I spec -I rest_spec -I rpc/ruby -fdoc'
  t.pattern    = 'rest_spec/use_messagepack_transport.rb'
}

desc "Run all tests in rpc_spec directory"
task :rpc_spec do |task|
  sh "PYTHONPATH=./agent_services/python/src/:./agent_services/python/test/:./agent_services/python/rpc_test/:./rpc/python/:./rpc_spec python ./rpc_spec/main.py"
end

desc "Run all python tests"
task :python_spec do |task|
  sh "PYTHONPATH=./agent_services/python/src/:./agent_services/python/test/ python -m unittest discover -t ./agent_services/python/test/ -s ./agent_services/python/test/"
end

desc "Run all specs in agent_service/python/rpc_test directory"
RSpec::Core::RakeTask.new(:python_rpc_spec) {|t|
  t.rspec_opts = '-I src -I spec -I rest_spec -I rpc/ruby -I agent_services/python/rpc_test -fdoc'
  t.pattern    = 'agent_services/python/rpc_test/all_specs.rb'
}

desc 'Run RuboCop on the src/spec directory'
task :lint => [:lint_src, :lint_spec, :lint_python_src]

RuboCop::RakeTask.new(:lint_src) do |task|
  init_rubocop_task(task, ['src','sample_agents/src'])
end
RuboCop::RakeTask.new(:lint_spec) do |task|
  init_rubocop_task(task, ['spec','rest_spec','sample_agents/spec', 'agent_services/python/rpc_test'])
end

task :lint_python_src do |task|
  sh "PYTHONPATH=./agent_services/python/src/:./agent_services/python/test/:./agent_services/python/rpc_test/:./rpc/python/ pylint --rcfile=config/pylint/pylintrc agent_services/python/src agent_services/python/test/ agent_services/python/rpc_test/"
end


desc 'Generate rpc serices and stubs.'
task :generate_stub do |task|
  ["agent", "logging", "health_check"].each do |mod|
    sh "grpc_tools_ruby_protoc -I ./rpc/protos --ruby_out=rpc/ruby --grpc_out=rpc/ruby ./rpc/protos/#{mod}.proto"
    sh "python -m grpc_tools.protoc -I./rpc/protos --python_out=./rpc/python --grpc_python_out=./rpc/python ./rpc/protos/#{mod}.proto"
  end
end

RDoc::Task.new do |rd|
  rd.rdoc_dir = 'build/rdocs'
  rd.rdoc_files.include(
    "src/jiji/model/agents/agent.rb",
    "src/jiji/model/agents/builtin_files/signals.rb",
    "src/jiji/model/agents/builtin_files/cross.rb",
    "src/jiji/model/graphing/graph_factory.rb",
    "src/jiji/model/graphing/graph.rb",
    "src/jiji/model/notification/notificator.rb",
    "src/jiji/model/trading/account.rb",
    "src/jiji/model/trading/closing_policy.rb",
    "src/jiji/model/trading/economic_calendar_information.rb",
    "src/jiji/model/trading/order.rb",
    "src/jiji/model/trading/pair.rb",
    "src/jiji/model/trading/position.rb",
    "src/jiji/model/trading/positions.rb",
    "src/jiji/model/trading/tick.rb",
    "src/jiji/model/trading/brokers/broker_proxy.rb",
    "src/jiji/model/trading/brokers/abstract_broker.rb",
    "src/jiji/model/trading/rate.rb")
  rd.options << '--charset=UTF-8 '
end

desc 'Release new version.'
task :release, ["version"] do |task, args|
  version = args.version

  merge_branch
  update_version(version)
  bulid_release_js
  commit_changes(version)
  push_to_remote_repository
  add_tags(version)
  update_dev_branch
end

def merge_branch
  sh 'git checkout master'
  sh 'git pull origin develop'
end
def update_version(version)
  src = IO.read('./src/jiji/version.rb')
  check_version(src, version)
  src = src.gsub(/VERSION\ \=\ \'[^\']*\'/, "VERSION = '#{version}'")
  IO.write('./src/jiji/version.rb', src)
end
def bulid_release_js
  cd 'sites' do
    sh 'gulp'
  end
end
def commit_changes(version)
  sh "git commit -a -m 'release #{version}'"
end
def push_to_remote_repository
  sh 'git push origin master'
end
def add_tags(version)
  sh "git tag 'v#{version}'"
  sh 'git push --tag'
end
def update_dev_branch
  sh 'git checkout develop'
  sh 'git pull --rebase origin master'
end
def extract_version(src)
  strs = src.scan(/VERSION\ \=\ \'([^\']*)\'/)
  Gem::Version.create(strs[0][0])
end
def check_version(src, new_version)
  current = extract_version(src)
  new_version = Gem::Version.create(new_version)
  if current >= new_version
    raise "illegal version. new=#{new_version} current=#{current}"
  end
end

def init_rubocop_task(task,src_dirs)
  task.patterns = src_dirs.map do |dir|
    "#{dir}/**/*.rb"
  end
  task.patterns += ['config/**/*.rb', 'config.ru'] if src_dirs.first == 'src'
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
