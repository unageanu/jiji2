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

    def create_agents(agent_setting, broker, graph_factory, backtest_id = nil,
      fail_on_error = false, ignore_agent_creation_error = false)
      agents = Jiji::Model::Agents::Agents.get_or_create(
        backtest_id, logger, fail_on_error)
      create_and_restore_agents(graph_factory, broker, backtest_id,
        agents, agent_setting, fail_on_error, ignore_agent_creation_error)
      agents
    end

    def create_agents_builder(graph_factory, broker, backtest_id = nil)
      Jiji::Model::Agents::AgentsUpdater.new(
        agent_registry, broker, graph_factory, nil, logger)
    end

    def create_graph_factory(id = nil)
      Jiji::Model::Graphing::GraphFactory.new(id)
    end

    def generate_uuid(agent_setting)
      return nil unless agent_setting
      agent_setting.each do |setting|
        setting[:uuid] = create_uuid unless setting.include?(:uuid)
      end
    end

    def create_and_restore_agents(graph_factory, broker, backtest_id,
      agents, agent_setting, fail_on_error, ignore_agent_creation_error)
      create_agents_builder(graph_factory, broker, backtest_id) \
        .update(agents, agent_setting || [], fail_on_error)
      agents.restore_state
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise e unless ignore_agent_creation_error
    end

    def create_uuid
      SecureRandom.uuid
    end
  end
end
