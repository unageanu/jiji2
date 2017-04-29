# coding: utf-8

require 'grpc'

module Jiji::Rpc::Converters
  module OrderConverter
    include Jiji::Rpc

    def convert_orders_to_pb(orders)
      return nil unless orders
      Orders.new(orders: orders.map do |order|
        convert_order_to_pb(order)
      end)
    end

    def convert_orders_options_from_pb(option)
      return nil unless option
      {
        stop_loss:     number_or_nil(option.stop_loss),
        take_profit:   number_or_nil(option.take_profit),
        trailing_stop: number_or_nil(option.trailing_stop),
        price:         number_or_nil(option.price),
        expiry:        convert_timestamp_from_pb(option.expiry),
        lower_bound:   number_or_nil(option.lower_bound),
        upper_bound:   number_or_nil(option.upper_bound)
      }
    end

    def convert_order_result_to_pb(result)
      return nil unless result
      OrderResponse.new({
        order_opened:  convert_order_to_pb(result.order_opened),
        trade_opened:  convert_order_to_pb(result.trade_opened),
        trade_reduced: convert_position_info_to_pb(result.trade_reduced),
        trades_closed: (result.trades_closed || []).map do |position|
          convert_position_info_to_pb(position)
        end
      })
    end

    def convert_order_from_pb(order)
      return nil unless order
      converted = Jiji::Model::Trading::Order.new(
        order.pair_name.to_sym, order.internal_id, order.sell_or_buy.to_sym,
        order.type.to_sym, convert_timestamp_from_pb(order.last_modified))
      update_order_properties(converted, order)
      converted
    end

    def convert_order_to_pb(order)
      return nil unless order
      Order.new(convert_hash_values_to_pb(order.to_h))
    end

    def convert_position_info_to_pb(position)
      return nil unless position
      PositionInfo.new(convert_hash_values_to_pb(position.to_h))
    end

    private

    def update_order_properties(converted, order)
      converted.units = number_or_nil(order.units)
      converted.price = number_or_nil(order.price)
      converted.expiry = convert_timestamp_from_pb(order.expiry)
      converted.lower_bound = number_or_nil(order.lower_bound)
      converted.upper_bound = number_or_nil(order.upper_bound)
      update_colsing_options(converted, order)
    end

    def update_colsing_options(converted, order)
      converted.stop_loss = number_or_nil(order.stop_loss)
      converted.take_profit = number_or_nil(order.take_profit)
      converted.trailing_stop = number_or_nil(order.trailing_stop)
    end
  end
end
