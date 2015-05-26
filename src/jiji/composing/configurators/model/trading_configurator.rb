# coding: utf-8

module Jiji::Composing::Configurators
  class TradingConfigurator < AbstractConfigurator

    include Jiji::Model

    def configure(container)
      configure_base_components(container)
      configure_rmt_components(container)
      configure_backtest_components(container)
    end

    def configure_base_components(container)
      container.configure do
        object :position_repository,         Trading::PositionRepository.new
        object :pairs,                       Trading::Pairs.new
        object :tick_repository,             Trading::TickRepository.new
      end
    end

    def configure_rmt_components(container)
      container.configure do
        object :rmt,                         Trading::RMT.new
        object :rmt_broker,                  Trading::Brokers::RMTBroker.new
        object :rmt_next_tick_job_generator,
          Trading::Internal::RMTNextTickJobGenerator.new
      end
    end

    def configure_backtest_components(container)
      container.configure do
        object :back_test_thread_pool,       Thread.pool(2)
        object :back_test_repository,        Trading::BackTestRepository.new
      end
    end

  end
end
