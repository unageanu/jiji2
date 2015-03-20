# coding: utf-8

require 'encase'
require 'thread'

module Jiji::Model::Trading::Jobs
  class NotifyNextTickJob

    def exec(trading_context, queue)
      before_do_next(trading_context, queue)
      trading_context.agents.next_tick(
        trading_context.broker.tick,  trading_context.broker)
      after_do_next(trading_context, queue)
    end

    def before_do_next(trading_context, queue)
      trading_context.broker.refresh
    end

    def after_do_next(_trading_context, queue)
    end

  end

  class NotifyNextTickJobForRMT < NotifyNextTickJob

    include Jiji::Model::Trading::Internal

    def after_do_next(trading_context, queue)
      store_rates(trading_context)
      store_trading_unit_hourly(trading_context)
    end

    def store_rates(context)
      rate_saver = get_or_create_rate_saver(context)
      rate_saver.save(context.broker.tick)
    end

    def store_trading_unit_hourly(context)
      now = context.time_source.now
      next_save_point = get_next_save_point(context)
      return if !next_save_point.nil? && next_save_point > now

      trading_unit_saver = get_or_create_trading_unit_saver(context)
      trading_unit_saver.save(context.broker.pairs, now)
      set_next_save_point(context, now + 60 * 60)
    end

    def get_or_create_rate_saver(trading_context)
      trading_context[:rate_saver] ||= RateSaver.new
    end

    def get_or_create_trading_unit_saver(trading_context)
      trading_context[:trading_unit_saver] ||= TradingUnitSaver.new
    end

    def get_next_save_point(context)
      context[:next_save_point]
    end

    def set_next_save_point(context, next_save_point)
      context[:next_save_point] = next_save_point
    end

  end

  class NotifyNextTickJobForBackTest < NotifyNextTickJob

    def after_do_next(context, queue)
      queue << self if context.broker.next?
      sleep 0.01
    end

  end
end
