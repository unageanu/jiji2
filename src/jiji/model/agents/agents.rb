# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'forwardable'

module Jiji::Model::Agents
  class Agents

    include Mongoid::Document
    include Jiji::Errors
    extend Forwardable

    def_delegators :@agents, :[], :include?, :each, :keys, :values

    attr_accessor :agents, :logger, :fail_on_error

    def initialize(backtest_id, agent_registry,
      components, fail_on_error = false)
      super()
      @updater       = Internal::AgentsUpdater.new(
        backtest_id, agent_registry, components)
      @logger        = components[:logger]
      @fail_on_error = fail_on_error
      @agents        = @updater.restore_agents_from_saved_state
    end

    def update_setting(new_setting, fail_on_error = false)
      @agents = @updater.update(@agents, new_setting, fail_on_error)
    end

    def next_tick(tick)
      @agents.values.each do |a|
        begin
          a.next_tick(tick)
        rescue Exception => e # rubocop:disable Lint/RescueException
          process_error(e)
        end
      end
    end

    def save_state
      @updater.save_state(@agents)
    end

    private

    def process_error(error)
      if @fail_on_error
        fail error
      else
        @logger.error(error) if @logger
      end
    end

  end
end
