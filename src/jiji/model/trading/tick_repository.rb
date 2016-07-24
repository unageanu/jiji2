# coding: utf-8

require 'encase'

module Jiji::Model::Trading
  class TickRepository

    include Encase
    include Jiji::Errors

    needs :securities_provider

    def fetch(pairs, start_time, end_time, interval_id = :fifteen_seconds)
      illegal_argument('illegal pairs') if pairs.blank? || pairs.empty?
      pairs.reduce([]) do |ticks, pair|
        ts = securities_provider.get.retrieve_tick_history(
          pair, start_time, end_time, interval_id)
        Tick.merge(ticks, ts)
      end
    end

    def range
      { start: Time.now - 60 * 60 * 24 * 365 * 10, end: Time.now }
    end

  end
end
