# frozen_string_literal: true

require 'jiji/model/securities/internal/oanda/converter'

module Jiji::Model::Securities::Internal::Oanda
  module RateRetriever
    include Jiji::Errors
    include Jiji::Model::Trading

    def retrieve_pairs
      @client.account(@account["id"]).instruments
        .show["instruments"].map { |item| convert_response_to_pair(item) }
    end

    def retrieve_current_tick
      prices = @client.account(@account["id"]).pricing(instruments: retrieve_all_pairs.join(",")).show
      convert_response_to_ticks(prices["prices"])
    end

    def retrieve_tick_history(pair_name, start_time,
      end_time, interval_id = :fifteen_seconds)
      interval = Intervals.instance.get(interval_id)
      converter = TickConverter.new(pair_name)
      RateFetcher.new(@client, converter)
        .fetch_and_fill(start_time, end_time, interval, pair_name)
    end

    def retrieve_rate_history(pair_name, interval_id, start_time, end_time)
      interval = Intervals.instance.get(interval_id)
      converter = RateConverter.new(pair_name, interval)
      RateFetcher.new(@client, converter)
        .fetch_and_fill(start_time, end_time, interval, pair_name)
    end

    private

    def retrieve_all_pairs
      @all_pairs ||= retrieve_pairs.map { |v| v.internal_id }
    end

    def convert_response_to_pair(item)
      Pair.new(
        Converter.convert_instrument_to_pair_name(item["name"]),
        item["name"], 10 ** item["pipLocation"].to_i, item["maximumOrderUnits"].to_i,
        10 ** (item["displayPrecision"].to_i * -1), item["marginRate"].to_f)
    end

    def convert_response_to_ticks(prices)
      values = prices.each_with_object({}) do |p, r|
        pair_name = Converter.convert_instrument_to_pair_name(p["instrument"])
        r[pair_name] = Tick::Value.new(
          p["bids"].map {|h| h["price"].to_f }.max,
          p["asks"].map {|h| h["price"].to_f }.min)
      end
      Tick.new(values, Time.now)
    end
  end

  class RateFetcher

    include Jiji::Model::Trading

    def initialize(client, converter)
      @client       = client
      @converter    = converter
    end

    def fetch_and_fill(start_time, end_time, interval, pair_name)
      @interval     = interval
      @start_time   = interval.calcurate_interval_start_time(start_time)
      @end_time     = interval.calcurate_interval_start_time(end_time)
      @pair_name    = pair_name

      fill(fetch(@interval, @start_time, @end_time))
    end

    private

    def fetch(interval, start_time, end_time, candle_format = 'BA')
      @client.instrument(to_instrument).candles({
        granularity:        to_granularity(interval),
        price:              candle_format,
        from:               start_time.getutc.to_datetime.rfc3339,
        to:                 end_time.getutc.to_datetime.rfc3339,
        alignmentTimezone:  Jiji::Utils::Times.iana_name(start_time),
        dailyAlignment:     0
      }).show
    end

    def to_granularity(interval)
      Converter.convert_interval_to_granularity(interval.id)
    end

    def to_instrument
      Converter.convert_pair_name_to_instrument(@pair_name)
    end

    def fill(rates)
      array = []
      current_time = @start_time
      while current_time < @end_time
        array << retrieve_rate_at(rates["candles"], current_time, array)
        current_time += @interval.ms / 1000
      end
      array
    end

    def retrieve_rate_at(rates, current_time, array)
      if !rates.empty? && Time.parse(rates.first["time"]) == current_time
        @converter.convert_value(rates.shift, current_time)
      else
        resolve_latest_rate(array, current_time)
      end
    end

    def resolve_latest_rate(array, current_time)
      if array.empty?
        rate = retrieve_latest_rate(current_time)
        @converter.convert_value(rate, current_time, true)
      else
        @converter.clone_value(array.last, current_time)
      end
    end

    def retrieve_latest_rate(start_time)
      try_to_retrieve_latest_rate_with_same_interval(start_time) \
      || retrieve_latest_rate_with_long_interval(start_time)
    end

    def try_to_retrieve_latest_rate_with_same_interval(time)
      rates = fetch(@interval, time - @interval.ms / 1000 * 20, time)
      rates["candles"].empty? ? nil : rates["candles"].last
    end

    def retrieve_latest_rate_with_long_interval(time)
      step = 60 * 60 * 24 * 7 * 4
      interval = Intervals.instance.get(:six_hours)
      4.times do
        rates = fetch(interval, time - step, time)
        return rates["candles"].last unless rates["candles"].empty?
        time -= step
      end
      illegal_argument('failed to load rate.')
    end

  end

  class RateConverter

    include Jiji::Model::Trading

    def initialize(pair_name, interval)
      @pair_name = pair_name
      @interval  = interval
    end

    def clone_value(value, time)
      Jiji::Model::Trading::Rate.new(value.pair, time, value.close,
        value.close, value.close, value.close, 0, time + @interval.ms / 1000)
    end

    def convert_value(value, time = Time.parse(value.time), using_close_value = false)
      if using_close_value
        create_rate_using_close_value(value, time)
      else
        create_rate(value, time)
      end
    end

    def create_rate(value, time)
      Rate.new(@pair_name, time,
        convert_response_to_tick_value('o', value),
        convert_response_to_tick_value('c', value),
        convert_response_to_tick_value('h', value),
        convert_response_to_tick_value('l', value),
        value["volume"])
    end

    def create_rate_using_close_value(value, time)
      close = convert_response_to_tick_value('c', value)
      Rate.new(@pair_name, time, close, close, close, close, value["volume"])
    end

    def convert_response_to_tick_value(id, item)
      Tick::Value.new(
        item["bid"][id].to_f,
        item["ask"][id].to_f)
    end

  end

  class TickConverter

    include Jiji::Model::Trading

    def initialize(pair_name)
      @pair_name = pair_name
    end

    def clone_value(value, time)
      Tick.new(value.values, time)
    end

    def convert_value(value, time = value.time, using_close_value = false)
      p value
      values = {}
      values[@pair_name] = create_tick_value(value, using_close_value)
      Tick.new(values, time)
    end

    def create_tick_value(value, using_close_value)
      if using_close_value
        Tick::Value.new(value["bid"]["c"].to_f, value["ask"]["c"].to_f)
      else
        Tick::Value.new(value["bid"]["o"].to_f, value["ask"]["o"].to_f)
      end
    end

  end
end
