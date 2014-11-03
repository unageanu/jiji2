require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
 
task :default => :spec

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) {|t|
  t.rspec_opts = '-I src -I spec'
}
