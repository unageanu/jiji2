# coding: utf-8

require 'encase'

module Jiji::Model::Trading::Internal
  class TradingUnitSaver

    def initialize
      @current = {}
    end

    def save(pairs, timestamp)
      pairs.each do |v|
        if  changed?(v)
          save_trading_unit(v, timestamp)
          update_current(v)
        end
      end
    end

    private

    def changed?(value)
      current = @current[value.name]
      current.nil? \
          || current.trade_unit != value.trade_unit
    end

    def save_trading_unit(value, timestamp)
      pair = Jiji::Model::Trading::Pairs.instance.create_or_get(value.name)
      TradingUnit.new do |t|
        t.pair_id      = pair.pair_id
        t.trading_unit = value.trade_unit
        t.timestamp    = timestamp
      end.save
    end

    def update_current(value)
      @current[value.name] = value
    end

  end
end
