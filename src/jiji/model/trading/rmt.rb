# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/trading/internal/worker_mixin'

module Jiji::Model::Trading
  class RMT

    include Encase
    include Jiji::Errors
    include Jiji::Model::Trading
    include Jiji::Model::Trading::Internal::WorkerMixin

    needs :setting_repository
    needs :rmt_broker
    needs :rmt_next_tick_job_generator

    attr_reader :process, :trading_context

    def setup
      @setting_repository.securities_setting.setup
      setup_rmt_process
    end

    def tear_down
      stop_rmt_process
    end

    private

    def setup_rmt_process
      @agents          = create_agents(@broker)
      @trading_context = create_trading_context
      @process         = create_process(trading_context)

      @process.start
      @rmt_next_tick_job_generator.start(@process.job_queue)
    end

    def stop_rmt_process
      @rmt_next_tick_job_generator.stop
      @process.stop
    end

    def create_trading_context
      TradingContext.new(@agents, rmt_broker, time_source, logger)
    end

    def create_process(trading_context)
      Process.new(trading_context, Thread.pool(1), false)
    end

  end
end
