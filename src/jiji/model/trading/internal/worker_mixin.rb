# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'securerandom'

module Jiji::Model::Trading::Internal
  module WorkerMixin
    include Encase

    needs :logger_factory
    needs :time_source
    needs :agent_registry

    attr_reader :process

    private

    def create_agents(agent_setting, broker, graph_factory, backtest = nil,
      fail_on_error = false, ignore_agent_creation_error = false)
      agents = Jiji::Model::Agents::Agents.get_or_create(
        backtest, @logger, fail_on_error)
      create_and_restore_agents(graph_factory, broker, backtest, agents,
        agent_setting, fail_on_error, ignore_agent_creation_error)
      agents
    end

    def create_agents_builder(graph_factory, broker)
      Jiji::Model::Agents::AgentsUpdater.new(
        agent_registry, broker, graph_factory, nil, @logger)
    end

    def create_graph_factory(backtest = nil)
      Jiji::Model::Graphing::GraphFactory.new(backtest)
    end

    def generate_uuid(agent_setting)
      return nil unless agent_setting
      agent_setting.each do |setting|
        setting[:uuid] = create_uuid unless setting.include?(:uuid)
      end
    end

    def create_and_restore_agents(graph_factory, broker, backtest,
      agents, agent_setting, fail_on_error, ignore_agent_creation_error)
      create_agents_builder(graph_factory, broker) \
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
