# coding: utf-8

require 'grpc'

module Jiji::Rpc
  module  Converters

    include Jiji::Rpc

    def convert_property_settings(property_settings)
      property_settings.map do |item|
        PropertySetting.new({
          id: item[0], value: item[1].to_s
        })
      end
    end

    def convert_tick(tick)
      Tick.new(
        timestamp: convert_timestamp(tick.timestamp),
        values:    tick.map do |k, v|
          convert_tick_value(v, k.to_s)
        end
      )
    end

    def convert_tick_value(value, pair)
      Tick::Value.new(ask: value.ask, bid: value.bid, pair: pair)
    end

    def convert_pairs(pairs)
      pairs.map do |pair|
        convert_pair(pair)
      end
    end

    def convert_pair(pair)
      hash = pair.to_h
      hash[:name] = hash[:name].to_s
      hash[:internal_id] = hash[:internal_id].to_s
      Pair.new(hash)
    end

    def convert_rates(rates)
      Rates.new(rates: rates.map { |rate| convert_rate(rate)})
    end

    def convert_rate(rate)
      hash = rate.to_h
      hash[:pair] = hash[:pair].to_s
      hash[:timestamp] = convert_timestamp(hash[:timestamp])
      [:open, :close, :high, :low].each do |key|
        hash[key] = convert_tick_value(hash[key], rate.pair.to_s)
      end
      Rate.new(hash)
    end

    def convert_timestamp(timestamp)
      Google::Protobuf::Timestamp.new(
        seconds: timestamp.to_i, nanos: 0)
    end

  end
end
