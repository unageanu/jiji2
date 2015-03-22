# coding: utf-8

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

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

ENV['JIJI_ENV'] = 'test'
ENV['SECRET']   = 'abcdefghijklmnopqrstuvwxyz' * 3

module Jiji
  module Test
    module Mock end
  end
end

require 'pp'
require 'jiji'
require 'jiji/test/data_builder'
require 'jiji/test/test_container_factory'
require 'jiji/test/mock/mock_securities_plugin'
require 'jiji/test/mock/mock_broker'

Errors    = Jiji::Errors
