# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'jiji/web/transport/transportable'
require 'jiji/model/trading/internal/worker_mixin'

module Jiji::Model::Trading
  class BackTestProperties

    include Encase
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    needs :backtest_thread_pool
    needs :tick_repository
    needs :pairs

    store_in collection: 'backtests'
    has_many :graph,
      class_name: 'Jiji::Model::Graphing::Graph', dependent: :destroy
    has_many :position,
      class_name: 'Jiji::Model::Trading::Position', dependent: :destroy
    has_many :logdata,
      class_name: 'Jiji::Model::Logging::LogData', dependent: :destroy

    field :name,          type: String
    field :created_at,    type: Time
    field :memo,          type: String

    field :start_time,    type: Time
    field :end_time,      type: Time
    field :agent_setting, type: Array
    field :pair_names,    type: Array
    field :balance,       type: Integer, default: 0
    field :status,        type: Symbol,  default: :wait_for_start

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
      hash = {
        id:            _id,
        name:          name,
        memo:          memo,
        agent_setting: agent_setting,
        created_at:    created_at
      }
      insert_broker_setting_to_hash(hash)
      insert_status_to_hash(hash)
      hash
    end

    private

    def insert_broker_setting_to_hash(hash)
      hash.merge!({
        pair_names: pair_names,
        start_time: start_time,
        end_time:   end_time,
        balance:    balance
      })
    end

    def insert_status_to_hash(hash)
      if status == :running
        hash.merge!(retrieve_status_from_context)
      else
        hash[:status] = status
      end
    end

    def retrieve_status_from_context
      @process.post_exec do |context, _queue|
        {
          status:       context.status,
          progress:     context[:progress],
          current_time: context[:current_time]
        }
      end.value
    end

  end

  class BackTest < BackTestProperties

    include Jiji::Errors
    include Jiji::Model::Trading
    include Jiji::Model::Trading::Internal::WorkerMixin

    def setup(ignore_agent_creation_error = false)
      self.created_at = created_at || time_source.now
      generate_uuid(agent_setting)

      create_components(ignore_agent_creation_error)
      return unless status == :wait_for_start

      @process.start(create_default_jobs)

      self.status = :running
      save
    end

    def stop
      @process.stop if @process && @process.running?
      if (status == :running)
        self.status = retrieve_process_status
        save
      end
    end

    def retrieve_process_status
      @process.post_exec { |context, _queue| context.status }.value
    end

    def self.create_from_hash(hash)
      BackTest.new do |b|
        b.name          = hash['name']
        b.memo          = hash['memo']
        b.agent_setting = hash['agent_setting']

        load_broker_setting_from_hash(b, hash)
      end
    end

    def self.load_broker_setting_from_hash(backtest, hash)
      backtest.pair_names = (hash['pair_names'] || []).map { |n| n.to_sym }
      backtest.start_time = hash['start_time']
      backtest.end_time   = hash['end_time']
      backtest.balance    = hash['balance'] || 0
    end

    private

    def create_default_jobs
      [Jobs::NotifyNextTickJobForBackTest.new(start_time, end_time)]
    end

    def create_components(ignore_agent_creation_error = false)
      @logger          = logger_factory.create(self)
      graph_factory    = create_graph_factory(self)
      broker           = create_broker
      @agents          = create_agents(agent_setting, broker,
        graph_factory, self, true, ignore_agent_creation_error)
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
end
