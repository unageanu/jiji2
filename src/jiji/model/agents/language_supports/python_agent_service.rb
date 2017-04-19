# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'forwardable'
require 'agent_services_pb'

module Jiji::Model::Agents::LanguageSupports
  class PythonAgentService < AbstractRpcAgentService

    include Jiji::Rpc

    SERVER_URL = 'localhost:50051'.freeze

    def stub
      @stub ||= AgentService::Stub.new(
        SERVER_URL, :this_channel_is_insecure)
    end

    def health_check_service_stub
      @health_check_service_stub ||= HealthCheckService::Stub.new(
        SERVER_URL, :this_channel_is_insecure)
    end

  end
end
