# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'

module Jiji::Model::Trading::Internal
  class PositionBuilder

    include Jiji::Model::Trading
    include Jiji::Model::Trading::Utils

    def initialize(backtest = nil)
      @backtest = backtest
    end

    def build_from_tick(internal_id,
      pair_name, units, sell_or_buy, tick, options = {})
      position = Position.new do |p|
        initialize_trading_information(p, @backtest,
          internal_id, pair_name, units, sell_or_buy)
        initialize_price_and_time_from_tick(p, tick, pair_name, sell_or_buy)
        p.closing_policy = ClosingPolicy.create(options)
      end
      position
    end

    def build_from_order(order, tick, agent = nil)
      position = Position.new do |p|
        initialize_trading_information(p, @backtest, order.internal_id,
          order.pair_name, order.units, order.sell_or_buy)
        initialize_price_and_time(p, order.price, tick.timestamp)
        initialize_agent_information(p, agent)
        p.closing_policy = ClosingPolicy.create(order.extract_options)
      end
      position.update_price(tick)
      position
    end

    def build_from_trade(trade)
      Position.new do |p|
        initialize_trading_information_from_trade(p, trade)
        initialize_price_and_time(p, trade.price.to_f, trade.time)
        p.closing_policy = ClosingPolicy.create(
          extract_options_from_trade(trade))
      end
    end

    def split_and_close(position, units,
      price, time, agent = nil)
      position.update_state_for_reduce(units, time)
      create_splited_position(position, units,
        price, time, agent)
    end

    private

    def extract_options_from_trade(trade)
      {
        stop_loss:       trade.stop_loss,
        take_profit:     trade.take_profit,
        trailing_stop:   trade.trailing_stop,
        trailing_amount: trade.trailing_amount
      }
    end

    def create_splited_position(position,
      units, price, time, agent)
      new_position = Position.new do |p|
        initialize_trading_information_from_position(p, position, units)
        initialize_price_and_time(p, position.entry_price, position.entered_at)
        initialize_agent_information(p, agent)
        p.closing_policy = ClosingPolicy.create(position.closing_policy.to_h)
      end
      new_position.update_state_to_closed(price, time)
      new_position
    end

    def initialize_price_and_time(position, entry_price, time)
      position.entry_price   = entry_price
      position.entered_at    = time
    end

    def initialize_price_and_time_from_tick(
      position, tick, pair_name, sell_or_buy)
      position.entry_price   = PricingUtils.calculate_entry_price(
        tick, pair_name, sell_or_buy)
      position.current_price = PricingUtils.calculate_current_price(
        tick, pair_name, sell_or_buy)
      position.entered_at    = tick.timestamp
      position.updated_at    = tick.timestamp
    end

    def initialize_agent_information(position, agent)
      position.agent = agent
    end

    def initialize_trading_information_from_position(position, from, units)
      initialize_trading_information(position, from.backtest,
        from.internal_id + '_', from.pair_name, units, from.sell_or_buy)
    end

    def initialize_trading_information_from_trade(position, trade)
      pair_name = Jiji::Model::Securities::Internal::Oanda::Converter\
                  .convert_instrument_to_pair_name(trade.instrument)
      initialize_trading_information(position, @backtest,
        trade.id, pair_name, trade.units, trade.side.to_sym)
    end

    def initialize_trading_information(position,
      backtest, internal_id, pair_name, units, sell_or_buy)
      position.pair_name           = pair_name
      position.units               = units
      position.sell_or_buy         = sell_or_buy
      position.internal_id         = internal_id
      position.status              = :live
      position.backtest            = backtest
    end

  end
end
