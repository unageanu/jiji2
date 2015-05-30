
module Jiji::Model::Securities::Internal
  module Converter
    include Jiji::Model::Trading

    def convert_response_to_pair(item)
      Pair.new(
        Converter.convert_instrument_to_pair_name(item.instrument),
        item.instrument, item.pip.to_f, item.max_trade_units.to_i,
        item.precision.to_f, item.margin_rate.to_f)
    end

    def convert_response_to_tick(prices)
      timestamp = nil
      values = prices.each_with_object({}) do |p, r|
        timestamp ||= p.time
        pair_name = Converter.convert_instrument_to_pair_name(p.instrument)
        r[pair_name] = Tick::Value.new(p.ask.to_f, p.bid.to_f)
      end
      Tick.new(values, timestamp)
    end

    def convert_response_to_rate(pair_name, item)
      Rate.new(pair_name, item.time,
        convert_response_to_tick_value('open',  item),
        convert_response_to_tick_value('close', item),
        convert_response_to_tick_value('high',  item),
        convert_response_to_tick_value('low',   item))
    end

    def convert_response_to_tick_value(id, item)
      Tick::Value.new(
        item.method("#{id}_bid").call.to_f,
        item.method("#{id}_ask").call.to_f)
    end

    def self.convert_instrument_to_pair_name(instrument)
      instrument.gsub(/\_/, '').to_sym
    end

    def self.convert_pair_name_to_instrument(pair_name)
      "#{pair_name.to_s[0..2]}_#{pair_name.to_s[3..-1]}"
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def self.convert_interval_to_granularity(interval)
      case interval
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
