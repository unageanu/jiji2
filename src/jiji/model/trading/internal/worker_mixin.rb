# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Model::Trading::Internal
  module WorkerMixin

    include Encase

    needs :logger
    needs :time_source
    needs :agent_registry

    attr_reader :process

    def update_agent_setting(new_setting)
      @agents_builder.update( @agents, new_setting )
    end

    private

    def create_agents(broker, backtest_id=nil)
      normalized_agent_setting
      graph_factory = create_graph_factory(backtest_id)
      @agents_builder = Jiji::Model::Agents::AgentsBuilder.new(
        agent_registry, broker, graph_factory, nil, logger)
      @agents_builder.build(agent_setting)
    end

    def create_graph_factory(id)
      Jiji::Model::Graphing::GraphFactory.new(time_source, id)
    end

    def normalized_agent_setting
      self.agent_setting = (agent_setting || []).map do |item|
        item.with_indifferent_access
      end
    end

  end
end
