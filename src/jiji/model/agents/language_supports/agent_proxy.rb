# coding: utf-8

module Jiji::Model::Agents::LanguageSupports
  class AgentProxy

    include Jiji::Model::Agents::Agent

    def initialize(instance_id, agent_service)
      @instance_id = instance_id
      @agent_service = agent_service
    end

    def properties=(properties)
      @agent_service.set_properties(@instance_id, properties)
    end

    def post_create
      @agent_service.exec_post_create(@instance_id)
    end

    def next_tick(tick)
      @agent_service.next_tick(@instance_id, tick)
    end

    def execute_action(action)
      @agent_service.execute_action(@instance_id, action)
    end

    def state
      @agent_service.retrieve_agent_state(@instance_id)
    end

    def restore_state(state)
      @agent_service.restore_instance_state(@instance_id, state)
    end

    def destroy
      @agent_service.delete_agent_instance(@instance_id)
    end

  end
end
