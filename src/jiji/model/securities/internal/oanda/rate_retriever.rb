# coding: utf-8

require 'oanda_api'
require 'jiji/model/securities/internal/oanda/converter'

module Jiji::Model::Securities::Internal::Oanda
  module RateRetriever
    include Jiji::Errors
    include Jiji::Model::Trading

    def retrieve_pairs
      @client.instruments({
        account_id: @account.account_id,
        fields:     %w(displayName pip maxTradeUnits precision marginRate)
      }).get.map { |item| convert_response_to_pair(item) }
    end

    def retrieve_current_tick
      prices = @client.prices(instruments: retrieve_all_pairs).get
      convert_response_to_ticks(prices)
    end

    def retrieve_tick_history(pair_name, start_time, end_time)
      interval = Jiji::Model::Trading::Interval.new(:fifteen_seconds, 15 * 1000)
      converter = TickConverter.new(pair_name)
      RateFetcher.new(@client, converter)
        .fetch_and_fill(start_time, end_time, interval, pair_name)
    end

    def retrieve_rate_history(pair_name, interval_id, start_time, end_time)
      interval    = Intervals.instance.get(interval_id)
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
        Converter.convert_instrument_to_pair_name(item.instrument),
        item.instrument, item.pip.to_f, item.max_trade_units.to_i,
        item.precision.to_f, item.margin_rate.to_f)
    end

    def convert_response_to_ticks(prices)
      values = prices.each_with_object({}) do |p, r|
        pair_name = Converter.convert_instrument_to_pair_name(p.instrument)
        r[pair_name] = Tick::Value.new(p.ask.to_f, p.bid.to_f)
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

    def fetch(interval, start_time, end_time, candle_format = 'bidask')
      @client.candles({
        granularity:        to_granularity(interval),
        candle_format:      candle_format,
        start:              start_time.getutc.to_datetime.rfc3339,
        end:                end_time.getutc.to_datetime.rfc3339,
        alignment_timezone: Jiji::Utils::Times.iana_name(start_time),
        dailyAlignment:     0,
        instrument:         to_instrument
      }).get
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
      while  current_time < @end_time
        array << retrieve_rate_at(rates, current_time, array)
        current_time += @interval.ms / 1000
      end
      array
    end

    def retrieve_rate_at(rates, current_time, array)
      if !rates.empty? && rates.first.time == current_time
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
      try_to_retrieve_latest_rate_with_some_interval(start_time) \
      || retrieve_latest_rate_with_long_interval(start_time)
    end

    def try_to_retrieve_latest_rate_with_some_interval(time)
      rates = fetch(@interval, time - @interval.ms / 1000 * 20, time)
      rates.empty? ? nil : rates.last
    end

    def retrieve_latest_rate_with_long_interval(time)
      step = 60 * 60 * 24 * 7 * 4
      interval = Intervals.instance.get(:six_hours)
      4.times do
        rates = fetch(interval, time - step, time)
        return rates.last unless rates.empty?
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
        value.close, value.close, value.close, time + @interval.ms / 1000)
    end

    def convert_value(value, time = value.time, using_close_value = false)
      if using_close_value
        create_rate_using_close_value(value, time)
      else
        create_rate(value, time)
      end
    end

    def create_rate(value, time)
      Rate.new(@pair_name, time,
        convert_response_to_tick_value('open',  value),
        convert_response_to_tick_value('close', value),
        convert_response_to_tick_value('high',  value),
        convert_response_to_tick_value('low',   value))
    end

    def create_rate_using_close_value(value, time)
      close = convert_response_to_tick_value('close', value)
      Rate.new(@pair_name, time, close, close, close, close)
    end

    def convert_response_to_tick_value(id, item)
      Tick::Value.new(
        item.method("#{id}_bid").call.to_f,
        item.method("#{id}_ask").call.to_f)
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
      values = {}
      values[@pair_name] = create_tick_value(value, using_close_value)
      Tick.new(values, time)
    end

    def create_tick_value(value, using_close_value)
      if using_close_value
        Tick::Value.new(value.close_bid.to_f, value.close_ask.to_f)
      else
        Tick::Value.new(value.open_bid.to_f, value.open_ask.to_f)
      end
    end

  end
end
