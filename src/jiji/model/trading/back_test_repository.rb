# coding: utf-8

require 'encase'
require 'thread/pool'

module Jiji::Model::Trading
  class BackTestRepository

    include Encase
    include Jiji::Errors

    attr_accessor :container

    def initialize
      @backtests = {}
    end

    def on_inject
      load
    end

    def all
      @backtests.values
    end

    def runnings
      @backtests.values.reject do |b|
        b.retrieve_process_status != :running
      end
    end

    def register(config)
      backtest = BackTest.create_from_hash(config)
      setup_backtest(backtest)
      backtest.save

      @backtests[backtest.id] = backtest
      backtest
    end

    def get(id)
      @backtests[id] || not_found(id)
    end

    def delete(id)
      backtest = get(id)
      backtest.process.stop

      backtest.delete
      @backtests.delete(id)
    end

    def stop
      rest = all.reject do |t|
        status = t.retrieve_process_status
        if status == :wait_for_start
          t.stop
          true
        else
          false
        end
      end
      rest.each { |t| t.stop }
    end

    private

    def load
      @backtests = BackTest
                   .order_by(:created_at.asc)
                   .all.each_with_object(@backtests) do |t, r|
        setup_backtest(t)
        r[t.id] = t
        r
      end
    end

    def setup_backtest(backtest)
      container.inject(backtest)
      backtest.setup
      backtest
    end

  end
end
