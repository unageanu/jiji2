# coding: utf-8

require 'grpc'

module Jiji::Rpc::Converters
  module RateConverter
    include Jiji::Rpc

    def convert_rates_to_pb(rates)
      return nil unless rates
      Rates.new(rates: rates.map { |rate| convert_rate_to_pb(rate) })
    end

    def convert_rate_to_pb(rate)
      return nil unless rate
      Rate.new(convert_hash_values_to_pb(rate.to_h))
    end
  end
end
