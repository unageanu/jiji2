# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/trading/internal/worker_mixin'

module Jiji::Model::Trading
  class RMT

    include Encase
    include Jiji::Errors
    include Jiji::Model::Trading
    include Jiji::Model::Trading::Internal::WorkerMixin
    include Jiji::Model::Agents

    needs :setting_repository
    needs :rmt_broker
    needs :rmt_next_tick_job_generator

    attr_reader :process, :trading_context, :agents

    def setup
      @setting_repository.securities_setting.setup

      setup_rmt_process
      setup_next_tick_job_generator
    end

    def tear_down
      stop_next_tick_job_generator
      stop_rmt_process
    end

    def update_agent_setting(new_setting)
      @agents.update_setting(new_setting, true)
      agent_settings
    end

    def agent_settings
      AgentSetting.load.map { |s| s }
    end

    def setup_rmt_process
      @logger          = logger_factory.create
      @graph_factory   = create_graph_factory
      @broker          = rmt_broker
      @agents          = create_agents
      @trading_context = create_trading_context(@graph_factory)
      @process         = create_process(trading_context)

      @process.start
    end

    def stop_rmt_process
      @process.stop if @process
    end

    def setup_next_tick_job_generator
      @rmt_next_tick_job_generator.start(@process.job_queue)
    end

    def stop_next_tick_job_generator
      @rmt_next_tick_job_generator.stop
    end

    def balance_of_yesterday
      today     = Jiji::Utils::Times.round_day(time_source.now)
      yesterday = Jiji::Utils::Times.yesterday(today)
      data = fetch_balance_graph_data(yesterday, today)
      data.empty? ? nil : data[0].value[0]
    end

    private

    def fetch_balance_graph_data(yesterday, today)
      graph = @trading_context.graph_factory.create_balance_graph
      graph.fetch_data(yesterday, today, :one_day)
        .sort_by { |d| d.timestamp.to_i * -1 }
    end

    def create_trading_context(graph_factory)
      TradingContext.new(@agents, rmt_broker,
        graph_factory, time_source, @logger)
    end

    def create_process(trading_context)
      Process.new(trading_context, Thread.pool(1), false)
    end

  end
end
