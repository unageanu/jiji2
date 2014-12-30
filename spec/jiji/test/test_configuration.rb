# coding: utf-8

ENV["JIJI_ENV"]="test"

require 'pp'
require 'jiji/test/data_builder'
require 'jiji/test/test_container_factory'
require 'jiji/test/mock/mock_securities_plugin'

Errors    = Jiji::Errors