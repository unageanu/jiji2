# coding: utf-8

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