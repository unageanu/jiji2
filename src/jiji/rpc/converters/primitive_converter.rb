# coding: utf-8

require 'grpc'

module Jiji::Rpc::Converters
  module PrimitiveConverter
    include Jiji::Rpc

    def convert_hash_values_to_pb(hash)
      return nil unless hash
      hash.keys.each do |key|
        value = hash[key]
        if value.nil?
          hash.delete(key)
        else
          hash[key] = convert_hash_value_to_pb(hash[key])
        end
      end
      hash
    end

    def convert_hash_value_to_pb(value)
      if value.is_a? Time
        convert_timestamp_to_pb(value)
      elsif value.is_a? Symbol
        value.to_s
      elsif value.is_a? Jiji::Model::Trading::Tick::Value
        convert_tick_value_to_pb(value, nil)
      elsif value.is_a? BigDecimal
        value.to_f #TODO
      else
        value
      end
    end

    def convert_timestamp_to_pb(timestamp)
      return nil unless timestamp
      Google::Protobuf::Timestamp.new(
        seconds: timestamp.to_i, nanos: 0)
    end

    def convert_timestamp_from_pb(timestamp)
      return nil unless timestamp
      Time.at(timestamp.seconds)
    end

    def convert_property_settings_to_pb(property_settings)
      return [] unless property_settings
      property_settings.map do |item|
        PropertySetting.new({
          id: item[0].to_s, value: item[1].to_s
        })
      end
    end

    def number_or_nil(number, default_value = 0)
      return nil if number == default_value
      number
    end

    def string_or_nil(string, default_value = '')
      return nil if string == default_value
      string
    end

    def symbol_or_nil(string, default_value = '')
      return nil if string == default_value
      string.to_sym
    end
  end
end
