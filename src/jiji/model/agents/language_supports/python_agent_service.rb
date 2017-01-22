# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'forwardable'
require 'agent_services_pb'

module Jiji::Model::Agents::LanguageSupports
  class PythonAgentService < AbstractRpcAgentService

    include Jiji::Rpc

    def stub
      @stub ||= AgentService::Stub.new(
        'localhost:50051', :this_channel_is_insecure)
    end

  end
end
