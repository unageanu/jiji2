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

  end

  class NotifyNextTickJobForBackTest < NotifyNextTickJob

    def after_do_next(context, queue)
      queue << self if context.broker.next?
      sleep 0.01
    end

  end
end
