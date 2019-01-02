# frozen_string_literal: true

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'securerandom'

module Jiji::Model::Trading::Internal
  module WorkerMixin
    include Encase

    needs :logger_factory
    needs :time_source
    needs :agent_registry
    needs :mail_composer
    needs :push_notifier

    attr_reader :process

    def create_agent_instances(
      agent_setting, ignore_agent_creation_error = false)
      @agents.update_setting(agent_setting, !ignore_agent_creation_error)
    end

    private

    def create_agents(backtest = nil, fail_on_error = false)
      agents = Jiji::Model::Agents::Agents.new(backtest,
        agent_registry, collect_components, fail_on_error)
      agents
    end

    def collect_components
      {
        logger:         @logger,
        time_source:    time_source,
        agent_registry: agent_registry,
        mail_composer:  mail_composer,
        push_notifier:  push_notifier,
        graph_factory:  @graph_factory,
        broker:         @broker
      }
    end

    def create_graph_factory(backtest = nil, saving_interval = 60)
      Jiji::Model::Graphing::GraphFactory.new(backtest, saving_interval)
    end
  end
end
