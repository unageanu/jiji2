# coding: utf-8

require 'encase'
require 'thread'

module Jiji::Model::Trading::Jobs
  class NotifyNextTickJob

    def initialize
      @counter = 0
    end

    def exec(trading_context, queue)
      before_do_next(trading_context, queue)
      trading_context.agents.next_tick(trading_context.broker.tick)
      after_do_next(trading_context, queue)
    end

    def before_do_next(trading_context, queue)
      trading_context.broker.refresh
      refresh_positions_and_account_per_minutes(trading_context)
    end

    def after_do_next(trading_context, queue)
      time = trading_context.broker.tick.timestamp
      trading_context.graph_factory.save_data(time)
    end

    private

    def refresh_positions_and_account_per_minutes(trading_context)
      @counter += 1
      return if @counter < 4

      trading_context.broker.refresh_positions
      trading_context.broker.refresh_account
      @counter = 0
    end

  end

  class NotifyNextTickJobForRMT < NotifyNextTickJob

  end

  class NotifyNextTickJobForBackTest < NotifyNextTickJob

    def after_do_next(context, queue)
      queue << self if context.broker.next?
      sleep 0.01
    end

  end
end
