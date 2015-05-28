# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Model::Trading::Internal
  module WorkerMixin
    include Encase

    needs :logger
    needs :time_source
    needs :agent_registry

    attr_reader :process

    private

    def create_agents(broker, backtest_id = nil)
      create_agents_builder(broker, backtest_id) \
        .build(agent_setting || [])
    end

    def create_agents_builder(broker, backtest_id = nil)
      graph_factory = create_graph_factory(backtest_id)
      Jiji::Model::Agents::AgentsBuilder.new(
        agent_registry, broker, graph_factory, nil, logger)
    end

    def create_graph_factory(id)
      Jiji::Model::Graphing::GraphFactory.new(time_source, id)
    end
  end
end
