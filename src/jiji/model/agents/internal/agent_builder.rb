# frozen_string_literal: true

module Jiji::Model::Agents::Internal
  class AgentBuilder

    include Jiji::Model::Agents
    include Jiji::Errors

    def initialize(registry)
      @registry = registry
    end

    def create_agent(name, properties = {})
      cl = @registry.get_agent_class(name)
      agent = cl.new
      agent.properties = properties
      agent
    end

    def get_agent_property_infos(name)
      cl = @registry.get_agent_class(name)
      cl.respond_to?(:property_infos) ? cl.property_infos : []
    end

    def get_agent_description(name)
      cl = @registry.get_agent_class(name)
      cl.respond_to?(:description) ? cl.description : nil
    end

  end
end
