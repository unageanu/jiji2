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
      rates = retrieve_candles(pair_name, 'S15', start_time, end_time).get
      converter = TickConverter.new(pair_name)
      filler = RateFiller.new(start_time,
        end_time, 15, 'S15', pair_name, self, converter)
      filler.fill(rates)
    end

    def retrieve_rate_history(pair_name, interval, start_time, end_time)
      granularity = Converter.convert_interval_to_granularity(interval)
      interval = Intervals.instance.get(interval).ms / 1000
      rates = retrieve_candles(pair_name, granularity, start_time, end_time).get
      converter = RateConverter.new(pair_name, interval)
      filler = RateFiller.new(start_time, end_time,
        interval, granularity, pair_name, self, converter)
      filler.fill(rates)
    end

    def retrieve_candles(pair_name, interval,
      start_time, end_time, candle_format = 'bidask')
      @client.candles({
        instrument:    Converter.convert_pair_name_to_instrument(pair_name),
        granularity:   interval,
        candle_format: candle_format,
        start:         start_time.utc.to_datetime.rfc3339,
        end:           end_time.utc.to_datetime.rfc3339
      })
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
      timestamp = nil
      values = prices.each_with_object({}) do |p, r|
        timestamp ||= p.time
        pair_name = Converter.convert_instrument_to_pair_name(p.instrument)
        r[pair_name] = Tick::Value.new(p.ask.to_f, p.bid.to_f)
      end
      Tick.new(values, timestamp)
    end
  end

  class RateFiller

    def initialize(start_time, end_time, interval,
        granularity, pair_name, retriever, converter)
      @start_time   = start_time
      @end_time     = end_time
      @interval     = interval
      @granularity  = granularity
      @pair_name    = pair_name
      @retriever    = retriever
      @converter    = converter
    end

    def fill(rates)
      array = []
      current_time = @start_time
      while  current_time < @end_time
        array << retrieve_rate_at(rates, current_time, array)
        current_time += @interval
      end
      array
    end

    def retrieve_rate_at(rates, current_time, array)
      if !rates.empty? && rates.first.time == current_time
        @converter.convert_value(rates.shift)
      else
        resolve_latest_rate(array, current_time)
      end
    end

    def resolve_latest_rate(array, current_time)
      if array.empty?
        rate = retrieve_latest_rate(current_time)
        @converter.convert_value(rate, current_time)
      else
        @converter.clone_value(array.last, current_time)
      end
    end

    def retrieve_latest_rate(start_time)
      try_to_retrieve_latest_rate_with_some_interval(start_time) \
      || retrieve_latest_rate_with_long_interval(start_time)
    end

    def try_to_retrieve_latest_rate_with_some_interval(time)
      rates = @retriever.retrieve_candles(
        @pair_name, @granularity, time - @interval * 20, time).get
      rates.empty? ? nil : rates.last
    end

    def retrieve_latest_rate_with_long_interval(time)
      step = 60 * 60 * 24 * 7 * 4
      4.times do
        rates = @retriever.retrieve_candles(
          @pair_name, 'H6', time - step, time).get
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
        value.close, value.close, value.close, time + @interval)
    end

    def convert_value(value, time = value.time)
      Rate.new(@pair_name, time,
        convert_response_to_tick_value('open',  value),
        convert_response_to_tick_value('close', value),
        convert_response_to_tick_value('high',  value),
        convert_response_to_tick_value('low',   value))
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

    def convert_value(value, time = value.time)
      values = {}
      values[@pair_name] = create_tick_value(value, time)
      Tick.new(values, time)
    end

    def create_tick_value(value, time)
      if (time == value.time)
        Tick::Value.new(value.open_bid.to_f, value.open_ask.to_f)
      else
        Tick::Value.new(value.close_bid.to_f, value.close_ask.to_f)
      end
    end

  end
end
