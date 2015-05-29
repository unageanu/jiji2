# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'securerandom'

module Jiji::Model::Trading::Internal
  module WorkerMixin
    include Encase

    needs :logger
    needs :time_source
    needs :agent_registry

    attr_reader :process

    private

    def create_agents(agent_setting, broker, backtest_id = nil)
      agents = Jiji::Model::Agents::Agents.get_or_create(backtest_id, logger)
      create_agents_builder(broker, backtest_id) \
        .update(agents, agent_setting || [])
      agents.restore_state
      agents
    end

    def create_agents_builder(broker, backtest_id = nil)
      graph_factory = create_graph_factory(backtest_id)
      Jiji::Model::Agents::AgentsUpdater.new(
        agent_registry, broker, graph_factory, nil, logger)
    end

    def create_graph_factory(id)
      Jiji::Model::Graphing::GraphFactory.new(time_source, id)
    end

    def generate_uuid(agent_setting)
      return nil unless agent_setting
      agent_setting.each do |setting|
        setting[:uuid] = create_uuid unless setting.include?(:uuid)
      end
    end

    def create_uuid
      SecureRandom.uuid
    end
  end
end
