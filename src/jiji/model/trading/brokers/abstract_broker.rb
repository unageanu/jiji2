# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Model::Trading::Brokers
  class AbstractBroker

    include Jiji::Model::Trading

    attr_reader :positions, :account

    def initialize
      @positions_is_dirty = true
      @orders_is_dirty    = true
    end

    def pairs
      @pairs_cache ||= securities.retrieve_pairs
    end

    def tick
      @rates_cache ||= securities.retrieve_current_tick
    end

    def positions
      return @positions unless @positions_is_dirty
      load_positions
    end

    def orders
      return @orders  if !@orders_is_dirty && @orders
      load_orders
    end

    def buy(pair_name, units, type = :market, options = {})
      order(pair_name, :buy, units, type, options)
    end

    def sell(pair_name, units, type = :market, options = {})
      order(pair_name, :sell, units, type, options)
    end

    def modify_order(order)
      securities.modify_order(
        order.internal_id, order.extract_options_for_modify)
      order
    end

    def cancel_order(order)
      result = securities.cancel_order(order.internal_id)
      @orders_is_dirty    = true
      result
    end

    def modify_position(position)
      securities.modify_trade(
        position.internal_id,
        position.closing_policy.extract_options_for_modify)
      position.save
      position
    end

    def close_position(position)
      result = securities.close_trade(position.internal_id)
      @positions.apply_close_result(result)
      @positions_is_dirty = true
      ClosedPosition.new(result.internal_id,
        position.units, result.price, result.timestamp)
    end

    def destroy
      securities.destroy if securities
    end

    # for internal use.
    def refresh
      @rates_cache = nil
      @orders_is_dirty = true
      @positions.update_price(tick, pairs) if next?
    end

    # for internal use.
    def refresh_position
      @positions_is_dirty = true
    end

    # for internal use.
    def refresh_account
    end

    private

    def load_positions
      positions = securities.retrieve_trades
      @positions.update(positions)
      @positions.update_price(tick, pairs)
      @positions_is_dirty = false
      @positions.each { |p| p.attach_broker(self) }
      @positions
    end

    def load_orders
      @orders = securities.retrieve_orders
      @orders.each { |o| o.attach_broker(self) }
      @orders_is_dirty = false
      @orders
    end

    def order(pair_id, sell_or_buy, units, type, options)
      result = securities.order(pair_id, sell_or_buy, units, type, options)
      @positions_is_dirty = true
      @orders_is_dirty    = true
      @positions.apply_order_result(result, tick)
      result
    end

    def init_positions(initial_positions = [])
      @positions = Positions.new(initial_positions, position_builder, account)
    end

  end
end
