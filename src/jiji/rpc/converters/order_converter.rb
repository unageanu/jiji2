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

    def convert_order_options_from_pb(option)
      return nil unless option
      {
        stop_loss:     convert_decimal_from_pb(option.stop_loss),
        take_profit:   convert_decimal_from_pb(option.take_profit),
        trailing_stop: convert_optional_uint32_from_pb(option.trailing_stop),
        price:         convert_decimal_from_pb(option.price),
        expiry:        convert_timestamp_from_pb(option.expiry),
        lower_bound:   convert_decimal_from_pb(option.lower_bound),
        upper_bound:   convert_decimal_from_pb(option.upper_bound)
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

    DECIMAL_FIELD_KEYS = [
      :price,
      :lower_bound,
      :upper_bound,
      :stop_loss,
      :take_profit
    ].freeze

    def convert_order_to_pb(order)
      return nil unless order
      hash = order.to_h
      convert_numerics_to_pb_decimal(hash, DECIMAL_FIELD_KEYS)
      hash[:units] = convert_optional_uint64_to_pb(hash[:units])
      hash[:trailing_stop] = convert_optional_uint32_to_pb(hash[:trailing_stop])
      Order.new(convert_hash_values_to_pb(hash))
    end

    def convert_position_info_to_pb(position)
      return nil unless position
      hash = position.to_h
      convert_numerics_to_pb_decimal(hash, [
        :price,
        :profit_or_loss
      ])
      PositionInfo.new(convert_hash_values_to_pb(hash))
    end

    private

    def update_order_properties(converted, order)
      converted.units = convert_optional_uint64_from_pb(order.units)
      converted.price = convert_decimal_from_pb(order.price)
      converted.expiry = convert_timestamp_from_pb(order.expiry)
      converted.lower_bound = convert_decimal_from_pb(order.lower_bound)
      converted.upper_bound = convert_decimal_from_pb(order.upper_bound)
      update_colsing_options(converted, order)
    end

    def update_colsing_options(converted, order)
      converted.stop_loss = convert_decimal_from_pb(order.stop_loss)
      converted.take_profit = convert_decimal_from_pb(order.take_profit)
      converted.trailing_stop =
        convert_optional_uint32_from_pb(order.trailing_stop)
    end
  end
end
