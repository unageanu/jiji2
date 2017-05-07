# coding: utf-8

require 'grpc'
require 'jiji/rpc/converters/tick_converter'

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
      converter = hash_value_converters.find do |c|
        c.target?(value)
      end
      converter ? converter.convert(value) : value
    end

    def convert_numerics_to_pb_decimal(hash, keys)
      keys.each do |k|
        value = hash[k]
        next if value.nil?
        value = BigDecimal.new(value, 16) unless value.is_a?(BigDecimal)
        hash[k] = convert_decimal_to_pb(value)
      end
    end

    def convert_strings_to_optional_string(hash, keys)
      keys.each do |k|
        value = hash[k]
        next if value.nil?
        hash[k] = convert_optional_string_to_pb(value)
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

    def convert_decimal_to_pb(decimal)
      return nil unless decimal
      Jiji::Rpc::Decimal.new(value: decimal.to_s)
    end

    def convert_decimal_from_pb(decimal)
      return nil unless decimal
      BigDecimal.new(decimal.value)
    end

    def convert_optional_string_to_pb(string)
      return nil unless string
      Jiji::Rpc::OptionalString.new(value: string)
    end

    def convert_optional_string_from_pb(string)
      return nil unless string
      string.value
    end

    def convert_optional_uint32_to_pb(int)
      return nil unless int
      Jiji::Rpc::OptionalUInt32.new(value: int)
    end

    def convert_optional_uint32_from_pb(int)
      return nil unless int
      int.value
    end

    def convert_optional_uint64_to_pb(int)
      return nil unless int
      Jiji::Rpc::OptionalUInt64.new(value: int)
    end

    def convert_optional_uint64_from_pb(int)
      return nil unless int
      int.value
    end

    def convert_property_settings_to_pb(property_settings)
      return [] unless property_settings
      property_settings.map do |item|
        PropertySetting.new({
          id: item[0].to_s, value: item[1].to_s
        })
      end
    end

    # def number_or_nil(number, default_value = 0)
    #   return nil if number == default_value
    #   number
    # end
    #
    # def string_or_nil(string, default_value = '')
    #   return nil if string == default_value
    #   string
    # end
    #
    # def symbol_or_nil(string, default_value = '')
    #   return nil if string == default_value
    #   string.to_sym
    # end

    private

    def hash_value_converters
      @hash_value_converters ||= [
        TimeConverter.new,
        SymbolConverter.new,
        TickValueConverter.new,
        BigDecimalConverter.new,
        FloatConverter.new
      ]
    end
  end

  class ValueConverter

    include PrimitiveConverter

    def target?(value)
      false
    end

    def convert(value)
      value
    end

  end

  class TimeConverter < ValueConverter

    def target?(value)
      value.is_a? Time
    end

    def convert(value)
      convert_timestamp_to_pb(value)
    end

  end

  class SymbolConverter < ValueConverter

    def target?(value)
      value.is_a? Symbol
    end

    def convert(value)
      value.to_s
    end

  end

  class TickValueConverter < ValueConverter

    include TickConverter

    def target?(value)
      value.is_a? Jiji::Model::Trading::Tick::Value
    end

    def convert(value)
      convert_tick_value_to_pb(value, nil)
    end

  end

  class BigDecimalConverter < ValueConverter

    def target?(value)
      value.is_a? BigDecimal
    end

    def convert(value)
      convert_decimal_to_pb(value)
    end

  end

  class FloatConverter < ValueConverter

    def target?(value)
      value.is_a? Float
    end

    def convert(value)
      convert_decimal_to_pb(BigDecimal.new(value, 16))
    end

  end
end
