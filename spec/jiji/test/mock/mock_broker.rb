# coding: utf-8

require 'jiji/plugin/securities_plugin'

module Jiji::Test::Mock
  class MockBroker < Jiji::Model::Trading::Brokers::AbstractBroker

    include JIJI::Plugin::SecuritiesPlugin
    include Jiji::Model::Trading
    include Jiji::Utils

    def initialize
      super
      @time_source = TimeSource.new
    end

    def next?
      true
    end

    def retrieve_pairs
      [
        Pair.new(:EURJPY, 10_000),
        Pair.new(:EURUSD, 10_000),
        Pair.new(:USDJPY, 10_000)
      ]
    end

    def retrieve_tick
      new_tick
    end

    def new_tick
      now = @time_source.now
      pairs  = [:EURJPY, :USDJPY, :EURUSD]
      values = pairs.each_with_object({}) do |pair_name, r|
        r[pair_name] = new_tick_value(now.sec % 10)
        r
      end
      Tick.create(values, now)
    end

    def new_tick_value(seed)
      Tick::Value.new(
        100.00 + seed, 100.003 + seed, 2 + seed, 20 + seed)
    end

  end
end
