
module Jiji::Model::Securities::Internal::Oanda
  module Converter
    include Jiji::Model::Trading

    def self.convert_instrument_to_pair_name(instrument)
      instrument.delete('_').to_sym
    end

    def self.convert_pair_name_to_instrument(pair_name)
      "#{pair_name.to_s[0..2]}_#{pair_name.to_s[3..-1]}"
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
