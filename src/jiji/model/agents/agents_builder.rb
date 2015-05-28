# coding: utf-8

require 'encase'
require 'securerandom'
require 'set'

module Jiji::Model::Agents
  class AgentsBuilder

    def initialize(agent_registory,
      broker, graph_factory, notifier, logger)
      @agent_registory = agent_registory
      @broker          = broker
      @graph_factory   = graph_factory
      @notifier        = notifier
      @logger          = logger
    end

    def build(agent_setting)
      agents = agent_setting.each_with_object({}) do |setting, r|
        create_and_insert_new_agent(r, setting)
      end
      Agents.new(agents, @logger)
    end

    def update(agents, agent_setting)
      new_agents = agent_setting.each_with_object({}) do |setting, r|
        if setting[:uuid].nil? || !agents.include?(setting[:uuid])
          create_and_insert_new_agent(r, setting)
        else
          update_agent(r, agents, setting)
        end
      end
      agents.agents = new_agents
    end

    private

    def update_agent(r, agents, setting)
      uuid = setting[:uuid]
      agent = agents[uuid]

      agent.properties = setting[:properties]
      r[uuid] = agent
    end

    def create_and_insert_new_agent(r, setting)
      uuid = create_uuid
      r[uuid] = create_agent(setting)
      setting[:uuid] = uuid
    end

    def create_agent(setting)
      agent = @agent_registory.create_agent(
        setting[:name], setting[:properties] || {})
      inject_components_to(agent)
      agent
    end

    def inject_components_to(agent)
      agent.broker          = @broker
      agent.graph_factory   = @graph_factory
      agent.notifier        = @notifier
      agent.logger          = @logger
    end

    def create_uuid
      SecureRandom.uuid
    end

  end
end
