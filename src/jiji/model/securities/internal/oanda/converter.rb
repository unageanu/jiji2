# frozen_string_literal: true

module Jiji::Model::Securities::Internal::Oanda
  module Converter
    include Jiji::Model::Trading

    def self.convert_instrument_to_pair_name(instrument)
      instrument.delete('_').to_sym
    end

    def self.convert_pair_name_to_instrument(pair_name)
      "#{pair_name.to_s[0..2]}_#{pair_name.to_s[3..-1]}"
    end

    def self.convert_option_to_oanda(option)
      option.each_with_object({}) do |entry, r|
        r[entry[0].to_s.camelize(:lower).to_sym] =
          convert_option_value_to_oanda(entry[0], entry[1])
      end
    end

    def self.convert_option_value_to_oanda(key, value)
      if value.is_a? Hash
        convert_option_to_oanda(value)
      elsif value.is_a?(Time)
        value.utc.to_datetime.rfc3339
      else
        value
      end
    end

    def self.convert_option_from_oanda(option)
      option.each_with_object({}) do |entry, r|
        r[entry[0].to_s.underscore.downcase.to_sym] =
          convert_option_value_from_oanda(entry[0], entry[1])
      end
    end

    def self.convert_option_value_from_oanda(key, value)
      if value.is_a? Hash
        convert_option_from_oanda(value)
      elsif key === "gtdTime"
        Time.parse(value)
      elsif key === "price" || key === "distance"
        BigDecimal(value, 10)
      else
        value
      end
    end

    def self.convert_order_type_to_oanda(order_type)
      order_type.to_s.underscore.upcase.to_sym
    end

    def self.convert_order_type_from_oanda(order_type)
      order_type.to_s.sub(/_ORDER$/, '').downcase.camelize(:lower).to_sym
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def self.convert_interval_to_granularity(interval)
      case interval
      when :fifteen_seconds then 'S15'
      when :one_minute      then 'M1'
      when :fifteen_minutes then 'M15'
      when :thirty_minutes  then 'M30'
      when :one_hour        then 'H1'
      when :six_hours       then 'H6'
      when :one_day         then 'D'
      else not_found('interval', interval: interval)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
