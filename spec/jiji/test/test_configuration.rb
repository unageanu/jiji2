# coding: utf-8

require 'jiji/test/configurations/build_directory_configuration'
require 'jiji/test/configurations/coverage_configuration'
require 'jiji/test/configurations/rspec_configuration'
require 'jiji/test/configurations/mail_configuration'
require 'jiji/test/configurations/environment_configuration'

module Jiji
  module Test
    module Mock end
  end
end

require 'jiji'
require 'pp'
require 'jiji/test/data_builder'
require 'jiji/test/virtual_securities_builder'
require 'jiji/test/test_container_factory'
require 'jiji/test/matchers'
require 'jiji/test/mock/mock_broker'
require 'jiji/test/shared_contexts'

Errors    = Jiji::Errors
