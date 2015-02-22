# coding: utf-8

require 'simplecov'

SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/src/jiji/web/"
  add_filter "/spec/"
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end


ENV["JIJI_ENV"]="test"

module Jiji
  module Test end
end

require 'pp'
require 'jiji'
require 'jiji/test/data_builder'
require 'jiji/test/test_container_factory'
require 'jiji/test/mock/mock_securities_plugin'
require 'jiji/test/mock/mock_broker'

Errors    = Jiji::Errors