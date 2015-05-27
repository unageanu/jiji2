# coding: utf-8

module Jiji::Test::Mock
  class MockSecurities

    include Jiji::Errors
    include Jiji::Model::Trading

    attr_reader   :config
    attr_writer   :pairs
    attr_accessor :seed

    def initialize(config)
      @config = config
      @serial = 0
      @seed   = 0

      @data_builder = Jiji::Test::DataBuilder.new
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
      Tick.new( {
        EURUSD: Tick::Value.new(1.1234 + @seed, 1.1236 + @seed),
        USDJPY: Tick::Value.new(112.10 + @seed, 112.12 + @seed),
        EURJPY: Tick::Value.new(135.30 + @seed, 135.33 + @seed)
      }, Time.utc(2015, 5, 1) )
    end

    def retrieve_tick_history( pair_name, start_time, end_time )
      i=-1
      create_timestamps( 15, start_time, end_time ).map do |time|
        @data_builder.new_tick((i+=1) % 10, Time.at(time))
      end
    end

    def retrieve_rate_history( pair_name, interval, start_time, end_time )
      interval_ms = Jiji::Utils::AbstractHistoricalDataFetcher \
        .resolve_collecting_interval(interval)
      create_timestamps( interval_ms/1000, start_time, end_time ).map do |time|
        Rate.new( pair_name, time, 112, 112.10, 113, 111 )
      end
    end

    def order(_pair, sell_or_buy, count)
      @serial += 1
      Position.new(@serial)
    end

    def commit(_position_id, count)
    end

    def self.register_securities_to(factory)
      factory.register_securities(:MOCK,  'モック',  [], self)
      factory.register_securities(:MOCK2, 'モック2', [], MockSecurities2)
    end

    private

    def create_timestamps( interval, start_time, end_time )
      start_time.to_i.step(end_time.to_i-1, interval).map {|t| Time.at(t) }
    end

    Position = Struct.new(:position_id)
    
  end

  class MockSecurities2 < MockSecurities
  end
end
