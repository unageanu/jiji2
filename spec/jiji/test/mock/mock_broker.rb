# frozen_string_literal: true

module Jiji::Test::Mock
  class MockBroker < Jiji::Model::Trading::Brokers::AbstractBroker

    include Jiji::Model::Trading
    include Jiji::Utils

    attr_reader :position_builder

    def initialize
      super
      @time_source = TimeSource.new
      @position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
      init_positions
    end

    def next?
      true
    end

    def pairs
      [
        Pair.new(:EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
        Pair.new(:EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04),
        Pair.new(:USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
      ]
    end

    def tick
      new_tick
    end

    def refresh; end

    def new_tick
      now = @time_source.now
      pairs  = %i[EURJPY USDJPY EURUSD]
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
