# coding: utf-8

require 'grpc'

module Jiji::Rpc::Converters
  module TickConverter
    include Jiji::Rpc

    def convert_tick_to_pb(tick)
      return nil unless tick
      Tick.new(
        timestamp: convert_timestamp_to_pb(tick.timestamp),
        values:    tick.map do |k, v|
          convert_tick_value_to_pb(v, k.to_s)
        end
      )
    end

    def convert_tick_value_to_pb(value, pair)
      return nil unless value
      args = {
        ask: convert_decimal_to_pb(value.ask),
        bid: convert_decimal_to_pb(value.bid)
      }
      args[:pair] = pair if pair
      Tick::Value.new(args)
    end
  end
end
