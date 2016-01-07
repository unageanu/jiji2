# coding: utf-8

require 'oanda_api'

module Jiji::Model::Securities::Internal::Virtual
  module Ordering
    include Jiji::Errors
    include Jiji::Model::Trading
    include Jiji::Model::Trading::Utils

    def init_ordering_state(orders = [])
      @orders   = orders
      @order_id = 1
    end

    def order(pair_name, sell_or_buy, units, type = :market, options = {})
      order = create_order(pair_name, sell_or_buy, units, type, options)
      if order.carried_out?(@current_tick)
        return register_position(order)
      else
        @orders << order
        return OrderResult.new(order.clone, nil, nil, [])
      end
    end

    def retrieve_orders(count = 500, pair_name = nil, max_id = nil)
      @orders.map { |o| o.clone }.sort_by { |o| o.internal_id.to_i * -1 }
    end

    def retrieve_order_by_id(internal_id)
      find_order_by_internal_id(internal_id).clone
    end

    def modify_order(internal_id, options = {})
      order = find_order_by_internal_id(internal_id)
      MODIFIABLE_PROPERTIES.each do |key|
        order.method("#{key}=").call(options[key]) if options.include?(key)
      end
      order.clone
    end

    def cancel_order(internal_id)
      order = find_order_by_internal_id(internal_id)
      @orders = @orders.reject { |o| o.internal_id == internal_id }
      order.clone
    end

    private

    MODIFIABLE_PROPERTIES = [
      :units, :price, :expiry, :lower_bound,
      :upper_bound, :stop_loss, :take_profit,
      :trailing_stop
    ]

    def register_position(order)
      position = @position_builder.build_from_order(order, @current_tick)
      result = close_or_reduce_reverse_positions(position)
      if position.units > 0
        @positions << position
        order.units = position.units
      end
      create_order_result(order, position, result)
    end

    def create_order_result(order, position, result)
      if (order.type == :market)
        if position.units > 0
          return OrderResult.new(nil, order, nil, result[:closed])
        else
          return OrderResult.new(nil, nil, result[:reduced], result[:closed])
        end
      else
        return OrderResult.new(order, nil, nil, [])
      end
    end

    def close_or_reduce_reverse_positions(position)
      result = { closed: [], reduced: nil }
      reverse_positions = find_reverse_positions(position)
      reverse_positions.each do |r|
        close_or_reduce_reverse_position(result, r, position)
      end
      remove_closed_positions(result[:closed])
      result
    end

    def remove_closed_positions(closed)
      @positions = @positions.reject do |p|
        !(closed.find do |item|
          p.internal_id == item.internal_id
        end.nil?)
      end
    end

    def close_or_reduce_reverse_position(result, reverse_position, position)
      units = position.units
      return unless units > 0
      if reverse_position.units <= units
        result[:closed] << convert_to_closed_position(reverse_position)
        position.units -= reverse_position.units
      else
        reverse_position.units -= units
        position.units = 0
        result[:reduced] = convert_to_reduced_position(reverse_position)
      end
    end

    def find_reverse_positions(position)
      @positions.select do |t|
        t.pair_name == position.pair_name \
        && t.sell_or_buy != position.sell_or_buy
      end
    end

    def find_order_by_internal_id(internal_id)
      @orders.find { |o| o.internal_id == internal_id } \
      || error('order not found')
    end

    def update_orders(tick)
      @orders = @orders.reject do |order|
        process_order(tick, order)
      end
    end

    def process_order(tick, order)
      return true if !order.expiry.nil? && order.expiry <= tick.timestamp
      if order.carried_out?(tick)
        register_position(order)
        true
      else
        false
      end
    end

    def error(message)
      fail OandaAPI::RequestError, message
    end

    def create_order(pair_name, sell_or_buy, units, type, options)
      order = Jiji::Model::Trading::Order.new(
        pair_name, new_id, sell_or_buy, type, @current_tick.timestamp)
      order.units   = units
      order.price   = resolve_price(
        type, pair_name, sell_or_buy, options, @current_tick)
      init_optional_properties(order, options)
      order
    end

    def new_id
      (@order_id += 1).to_s
    end

    def init_optional_properties(order, options)
      order.expiry        = options[:expiry] || nil
      [:lower_bound, :upper_bound,
       :stop_loss, :take_profit, :trailing_stop].each do |key|
        order.method("#{key}=").call(options[key] || 0)
      end
    end

    def resolve_price(type, pair_name, sell_or_buy, options, tick)
      return options[:price]  || nil if type != :market
      PricingUtils.calculate_entry_price(tick, pair_name, sell_or_buy)
    end

    def convert_to_closed_position(position, units = nil)
      price = PricingUtils.calculate_current_price(
        @current_tick, position.pair_name, position.sell_or_buy)
      ClosedPosition.new(position.internal_id,
        units || position.units, price, @current_tick.timestamp)
    end

    def convert_to_reduced_position(position)
      price = PricingUtils.calculate_current_price(
        @current_tick, position.pair_name, position.sell_or_buy)
      ReducedPosition.new(position.internal_id,
        position.units, price, @current_tick.timestamp)
    end
  end
end
