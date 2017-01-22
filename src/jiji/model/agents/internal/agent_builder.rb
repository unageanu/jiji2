# coding: utf-8

require 'encase'

module Jiji::Model::Agents::Internal
  class AgentBuilder

    include Encase
    include Jiji::Model::Agents
    include Jiji::Errors

    needs :agent_service_resolver

    def create_agent(name, properties, agents)
      source_name = AgentFinder.split_class_name(name)
      agent = agents[source_name[1]]
      not_found(AgentSource, name: source_name[1]) unless agent
      service = agent_service_resolver.resolve(agent.language)
      service.create_agent_instance(name, properties)
    end

  end
end
