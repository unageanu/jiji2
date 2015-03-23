require 'simplecov'
require 'codeclimate-test-reporter'

dir = File.join(ENV['CIRCLE_ARTIFACTS'] || 'build', 'coverage')
SimpleCov.coverage_dir(dir)
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/src/jiji/web/'
  add_filter '/spec/'
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
  ]
end
