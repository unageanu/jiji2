# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'jiji/web/transport/transportable'
require 'jiji/model/trading/internal/worker_mixin'

module Jiji::Model::Trading
  module BackTestFunctions
    def load_broker_setting_from_hash(hash)
      self.pair_names    = hash['pair_names']
      self.start_time    = hash['start_time']
      self.end_time      = hash['end_time']
      self.balance       = hash['balance'] || 0
    end

    private

    def insert_broker_setting_to_hash(hash)
      hash.merge({
        pair_names: pair_names,
        start_time: start_time,
        end_time:   end_time,
        balance:    balance
      })
    end

    def create_components
      graph_factory    = create_graph_factory
      broker           = create_broker
      @agents          = create_agents(
        agent_setting, graph_factory, broker, id)
      trading_context  = create_trading_context(broker, @agents, graph_factory)
      @process         = create_process(trading_context)
    end

    def create_broker
      pairs = (pair_names || []).map { |p| @pairs.get_by_name(p) }
      Brokers::BackTestBroker.new(_id, start_time, end_time,
        pairs, balance, @tick_repository)
    end

    def create_trading_context(broker, agents, graph_factory)
      TradingContext.new(agents,
        broker, graph_factory, time_source, @logger)
    end

    def create_process(trading_context)
      Process.new(trading_context, backtest_thread_pool, true)
    end
  end

  class BackTest

    include Encase
    include Jiji::Errors
    include Jiji::Model::Trading
    include Jiji::Model::Trading::Internal::WorkerMixin
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include BackTestFunctions

    needs :backtest_thread_pool
    needs :tick_repository
    needs :pairs

    store_in collection: 'backtests'

    field :name,          type: String
    field :created_at,    type: Time
    field :memo,          type: String

    field :start_time,    type: Time
    field :end_time,      type: Time
    field :agent_setting, type: Array
    field :pair_names,    type: Array
    field :balance,       type: Integer, default: 0

    validates :name,
      length:   { maximum: 200, strict: true },
      presence: { strict: true }

    validates :memo,
      length:      { maximum: 2000, strict: true },
      allow_nil:   true,
      allow_blank: true

    validates :created_at,
      presence: { strict: true }
    validates :start_time,
      presence: { strict: true }
    validates :end_time,
      presence: { strict: true }
    validates :pair_names,
      presence: { strict: true },
      length:   { minimum: 1 }
    validates :agent_setting,
      presence: { strict: true },
      length:   { minimum: 1 }
    validates :balance,
      presence:     { strict: true },
      numericality: {
        only_integer:             true,
        greater_than_or_equal_to: 0,
        strict:                   true
    }

    index(
      { created_at: 1, id: 1 },
      unique: true, name: 'backtests_created_at_id_index')

    attr_reader :process, :agents

    def to_h
      insert_broker_setting_to_hash({
        id:            _id,
        name:          name,
        memo:          memo,
        agent_setting: agent_setting,
        created_at:    created_at
      })
    end

    def self.create_from_hash(hash)
      BackTest.new do |b|
        b.name          = hash['name']
        b.memo          = hash['memo']
        b.agent_setting = hash['agent_setting']

        b.load_broker_setting_from_hash(hash)
      end
    end

    def setup
      self.created_at = time_source.now
      generate_uuid(agent_setting)

      create_components

      @process.start
      @process.post_job(Jobs::NotifyNextTickJobForBackTest.new)
    end

    def delete
      # TODO: delete positions, logs
      super
    end

  end
end
