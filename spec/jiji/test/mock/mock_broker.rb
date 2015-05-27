# coding: utf-8

module Jiji::Test::Mock
  class MockBroker < Jiji::Model::Trading::Brokers::AbstractBroker

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
        Pair.new(:EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
        Pair.new(:EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04),
        Pair.new(:USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
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
      Tick.new(values, now)
    end

    def new_tick_value(seed)
      Tick::Value.new(
        100.00 + seed, 100.003 + seed)
    end

  end
end
