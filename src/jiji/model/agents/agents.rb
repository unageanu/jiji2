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

    store_in collection: 'agent_states'

    field :backtest_id,  type: BSON::ObjectId
    field :states,       type: Hash, default: {}

    index(
      { backtest_id: 1 },
      unique: true, name: 'agent_states_backtest_id_index')

    attr_accessor :agents, :logger, :fail_on_error

    def initialize(backtest_id = nil, agents = {},
      logger = nil, fail_on_error = false)
      super()
      @agents        = agents
      @logger        = logger
      @fail_on_error = fail_on_error

      self.backtest_id = backtest_id
    end

    def self.get_or_create(backtest_id, logger, fail_on_error = false)
      agents = Agents.find_by(backtest_id: backtest_id) \
             || Agents.new(backtest_id, {}, logger, fail_on_error)
      agents.logger = logger
      agents.fail_on_error = fail_on_error
      agents
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
      self.states = @agents.each_with_object({}) do |pair, r|
        begin
          r[pair[0]] = pair[1].state
        rescue Exception => e # rubocop:disable Lint/RescueException
          process_error(e)
        end
      end
      save
    end

    def restore_state
      return unless states
      states.each do |k, v|
        begin
          agent = @agents[k]
          agent.restore_state(v) if agent
        rescue Exception => e # rubocop:disable Lint/RescueException
          process_error(e)
        end
      end
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
