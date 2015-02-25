# coding: utf-8

require 'jiji/plugin/securities_plugin'

module Jiji::Test::Mock
  class MockBroker < Jiji::Model::Trading::Brokers::AbstractBroker

    attr_reader :has_next

  end
end
