# coding: utf-8

module Jiji::Composing::Configurators
  class TradingConfigurator < AbstractConfigurator

    include Jiji::Model
    include Jiji::Model::Trading
    include Jiji::Model::Trading::Internal

    def configure(container)
      configure_base_components(container)
      configure_rmt_components(container)
      configure_backtest_components(container)
      configure_trading_summary_components(container)
    end

    def configure_trading_summary_components(container)
      container.configure do
        object :trading_summary_builder,
          TradingSummaries::TradingSummaryBuilder.new
      end
    end

    def configure_base_components(container)
      container.configure do
        object :position_repository,         PositionRepository.new
        object :position_builder,            PositionBuilder.new
        object :pairs,                       Pairs.new
        object :tick_repository,             TickRepository.new
      end
    end

    def configure_rmt_components(container)
      container.configure do
        object :rmt,                         RMT.new
        object :rmt_broker,                  Brokers::RMTBroker.new
        object :rmt_next_tick_job_generator, RMTNextTickJobGenerator.new
      end
    end

    def configure_backtest_components(container)
      container.configure do
        object :backtest_thread_pool,       Thread.pool(1)
        object :backtest_repository,        BackTestRepository.new
      end
    end

  end
end
