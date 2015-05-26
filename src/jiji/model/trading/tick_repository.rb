# coding: utf-8

require 'encase'

module Jiji::Model::Trading
  class TickRepository

    include Encase
    include Jiji::Errors

    needs :securities_provider

    def fetch(pairs, start_time, end_time)
      pairs.reduce([]) do |ticks, pair|
        Tick.merge(ticks, securities_provider.get.retrieve_tick_history(
          pair, start_time, end_time))
      end
    end

    def range
      { start: Time.now - 60*60*24*365*10, end: Time.now }
    end

  end
end
