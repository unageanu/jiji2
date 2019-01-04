# frozen_string_literal: true

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

    def build_from_tick(internal_id, pair_name,
      units, sell_or_buy, tick, account_currency, options = {})
      position = Position.new do |p|
        initialize_trading_information(p, @backtest,
          internal_id, pair_name, units, sell_or_buy)
        initialize_price_and_time_from_tick(
          p, tick, pair_name, sell_or_buy, account_currency)
        p.closing_policy = ClosingPolicy.create(options)
      end
      position
    end

    def build_from_order(order, tick, account_currency, agent = nil)
      position = Position.new do |p|
        initialize_trading_information(p, @backtest, order.internal_id,
          order.pair_name, order.units, order.sell_or_buy)
        initialize_price_and_time(p, order.price, tick.timestamp)
        initialize_agent_information(p, agent)
        p.closing_policy = ClosingPolicy.create(order.extract_options)
      end
      position.update_price(tick, account_currency)
      position
    end

    def build_from_trade(trade)
      Position.new do |p|
        initialize_trading_information_from_trade(p, trade)
        initialize_price_and_time(p, trade["price"].to_f, Time.parse(trade["openTime"]), nil)
        p.closing_policy = ClosingPolicy.create_from_trade(trade)
      end
    end

    def build_from_trade_opend_of_order_result(trade)
      Position.new do |p|
        initialize_trading_information_from_trade_opend_of_order_result(p, trade)
        initialize_price_and_time(p, trade["price"].to_f, Time.parse(trade["time"]), nil)
        p.closing_policy = ClosingPolicy.create_from_trade(trade)
      end
    end

    def split_and_close(position, units,
      price, time, agent = nil)
      position.update_state_for_reduce(units, time)
      create_splited_position(position, units,
        price, time, agent)
    end

    private

    def create_splited_position(position,
      units, price, time, agent)
      new_position = Position.new do |p|
        initialize_trading_information_from_position(p, position, units)
        initialize_price_and_time(p, position.entry_price, position.entered_at,
          position.current_counter_rate)
        initialize_agent_information(p, agent)
        p.closing_policy = ClosingPolicy.create(position.closing_policy.to_h)
      end
      new_position.update_state_to_closed(price, time)
      new_position
    end

    def initialize_price_and_time(position,
      entry_price, time, current_counter_rate = nil)
      position.entry_price          = entry_price
      position.entered_at           = time
      position.current_counter_rate = current_counter_rate
    end

    def initialize_price_and_time_from_tick(
      position, tick, pair_name, sell_or_buy, account_currency)
      position.entry_price   = PricingUtils.calculate_entry_price(
        tick, pair_name, sell_or_buy)
      position.current_price = PricingUtils.calculate_current_price(
        tick, pair_name, sell_or_buy)
      position.current_counter_rate = PricingUtils \
        .calculate_current_counter_rate(tick, pair_name, account_currency)
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

    def initialize_trading_information_from_trade_opend_of_order_result(position, trade)
      pair_name = Jiji::Model::Securities::Internal::Oanda::Converter\
        .convert_instrument_to_pair_name(trade["instrument"])
      initialize_trading_information(position, @backtest,
        trade["tradeID"], pair_name, trade["units"].to_i.abs,
        PricingUtils.detect_sell_or_buy(trade["units"]))
    end

    def initialize_trading_information_from_trade(position, trade)
      pair_name = Jiji::Model::Securities::Internal::Oanda::Converter\
        .convert_instrument_to_pair_name(trade["instrument"])
      initialize_trading_information(position, @backtest,
        trade["id"], pair_name, trade["currentUnits"].to_i.abs,
        PricingUtils.detect_sell_or_buy(trade["currentUnits"]))
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
