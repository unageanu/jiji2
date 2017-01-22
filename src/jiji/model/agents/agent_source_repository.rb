# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji::Model::Agents
  class AgentSourceRepository

    include Encase

    needs :agent_service_resolver

    def all
      AgentSource.all.order_by(:name.asc).map { |a| a }
    end

    def get_by_type(type)
      AgentSource.where(type: type).order_by(:name.asc).without(:body, :error)
    end

    def get_by_id(id)
      source = AgentSource.find(id)
      if source
        service = agent_service_resolver.resolve(source.language)
        service.evaluate(source)
      end
      source
    end

  end
end
