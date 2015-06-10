# coding: utf-8

require 'jiji/test/data_builder'

module Jiji::Test::Mock
  class MockSecurities < Jiji::Model::Securities::VirtualSecurities

    include Jiji::Errors
    include Jiji::Model::Trading

    attr_reader :config
    attr_writer :pairs
    attr_accessor :seed

    def initialize(config)
      @position_builder = Internal::PositionBuilder.new

      init_ordering_state
      init_trading_state

      @config = config
      @serial = 0
      @i = -1

      @data_builder = Jiji::Test::DataBuilder.new
    end

    def reset
      @i = -1
      @serial = 0
    end

    def destroy
    end

    def retrieve_pairs
      @pairs ||= [
        Pair.new(:EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
        Pair.new(:EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04),
        Pair.new(:USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
      ]
    end

    def retrieve_current_tick
      @current_tick = create_tick(
        SEEDS[(@i += 1) % SEEDS.length],
        Time.utc(2015, 5, 1) + @i * 15)
      update_orders(@current_tick)
      update_positions(@current_tick)
      @current_tick
    end

    def retrieve_tick_history(pair_name, start_time, end_time)
      i = -1
      create_timestamps(15, start_time, end_time).map do |time|
        create_tick(SEEDS[(i += 1) % SEEDS.length], time)
      end
    end
    SEEDS = [0, 0.26, 0.3, 0.303, 0.301, 0.4, 0.401, 0.35, 0.36, 0.2, 0.1]

    def retrieve_rate_history(pair_name, interval, start_time, end_time)
      if pair_name != :EURJPY && pair_name != :EURUSD && pair_name != :USDJPY
        not_found
      end
      interval_ms = Jiji::Model::Trading::Intervals.instance \
                    .resolve_collecting_interval(interval)
      create_timestamps(interval_ms / 1000, start_time, end_time).map do |time|
        Rate.new(pair_name, time, 112, 112.10, 113, 111)
      end
    end

    def self.register_securities_to(factory)
      factory.register_securities(:MOCK,  'モック',  [], self)
      factory.register_securities(:MOCK2, 'モック2', [], MockSecurities2)
    end

    private

    def create_timestamps(interval, start_time, end_time)
      start_time.to_i.step(end_time.to_i - 1, interval).map { |t| Time.at(t) }
    end

    def create_tick(seed, time = Time.utc(2015, 5, 1) + seed * 1000)
      Tick.new({
        EURUSD: Tick::Value.new(
          (BigDecimal.new(1.1234, 10) + seed).to_f,
          (BigDecimal.new(1.1236, 10) + seed).to_f),
        USDJPY: Tick::Value.new(
          (BigDecimal.new(112.10, 10) + seed).to_f,
          (BigDecimal.new(112.12, 10) + seed).to_f),
        EURJPY: Tick::Value.new(
          (BigDecimal.new(135.30, 10) + seed).to_f,
          (BigDecimal.new(135.33, 10) + seed).to_f)
      }, time)
    end

  end

  class MockSecurities2 < MockSecurities

  end
end
