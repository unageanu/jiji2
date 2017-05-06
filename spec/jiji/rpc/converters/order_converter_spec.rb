# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Rpc::Converters::OrderConverter do
  include_context 'use data_builder'

  class Converter

    include Jiji::Rpc::Converters

  end

  let(:converter) { Converter.new }

  Order = Jiji::Model::Trading::Order

  describe '#convert_order_to_pb' do
    it 'converts Order to Rpc::Order' do
      converted = converter.convert_order_to_pb(create_order)
      expect(converted.pair_name).to eq 'EURJPY'
      expect(converted.sell_or_buy).to eq 'buy'
      expect(converted.internal_id).to eq '10'
      expect(converted.type).to eq 'market'
      expect(converted.last_modified.seconds).to eq 10
      expect(converted.last_modified.nanos).to eq 0
      expect(converted.units).to eq 100_000
      expect(converted.price.value).to eq '110.0'
      expect(converted.expiry.seconds).to eq 20
      expect(converted.expiry.nanos).to eq 0
      expect(converted.lower_bound.value).to eq '109.0'
      expect(converted.upper_bound.value).to eq '111.0'
      expect(converted.stop_loss.value).to eq '108.0'
      expect(converted.take_profit.value).to eq '112.0'
      expect(converted.trailing_stop).to eq 10

      converted = converter.convert_order_to_pb(create_minimum_setting_order)
      expect(converted.pair_name).to eq 'USDJPY'
      expect(converted.sell_or_buy).to eq 'sell'
      expect(converted.internal_id).to eq '2'
      expect(converted.type).to eq 'limit'
      expect(converted.last_modified.seconds).to eq 1_491_015_699
      expect(converted.last_modified.nanos).to eq 0
      expect(converted.units).to eq 0
      expect(converted.price).to eq nil
      expect(converted.expiry).to eq nil
      expect(converted.lower_bound).to eq nil
      expect(converted.upper_bound).to eq nil
      expect(converted.stop_loss).to eq nil
      expect(converted.take_profit).to eq nil
      expect(converted.trailing_stop).to eq 0
    end
    it 'returns nil when an order is nil' do
      converted = converter.convert_order_to_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_orders_to_pb' do
    it 'converts an array of Order to Rpc::Orders' do
      orders = [
        create_order,
        create_minimum_setting_order,
        data_builder.new_order(30)
      ]
      converted = converter.convert_orders_to_pb(orders)
      expect(converted.orders.length).to eq 3

      converted = converter.convert_orders_to_pb([])
      expect(converted.orders.length).to eq 0
    end
    it 'returns nil when an order is nil' do
      converted = converter.convert_orders_to_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_order_from_pb' do
    it 'converts Rpc::Order to Order' do
      order = create_order
      rpc_order = converter.convert_order_to_pb(order)
      converted = converter.convert_order_from_pb(rpc_order)
      expect(converted).to eq order
      expect(converted.pair_name).to eq :EURJPY
      expect(converted.sell_or_buy).to eq :buy
      expect(converted.internal_id).to eq '10'
      expect(converted.type).to eq :market
      expect(converted.last_modified).to eq Time.at(10)
      expect(converted.units).to eq 100_000
      expect(converted.price).to eq 110
      expect(converted.expiry).to eq Time.at(20)
      expect(converted.lower_bound).to eq 109.0
      expect(converted.upper_bound).to eq 111.0
      expect(converted.stop_loss).to eq 108.0
      expect(converted.take_profit).to eq 112.0
      expect(converted.trailing_stop).to eq 10

      order = create_minimum_setting_order
      rpc_order = converter.convert_order_to_pb(order)
      converted = converter.convert_order_from_pb(rpc_order)
      expect(converted).to eq order
      expect(converted.pair_name).to eq :USDJPY
      expect(converted.sell_or_buy).to eq :sell
      expect(converted.internal_id).to eq '2'
      expect(converted.type).to eq :limit
      expect(converted.last_modified).to eq Time.new(2017, 4, 1, 12, 1, 39)
      expect(converted.units).to eq nil
      expect(converted.price).to eq nil
      expect(converted.expiry).to eq nil
      expect(converted.lower_bound).to eq nil
      expect(converted.upper_bound).to eq nil
      expect(converted.stop_loss).to eq nil
      expect(converted.take_profit).to eq nil
      expect(converted.trailing_stop).to eq nil
    end
    it 'returns nil when an order is nil' do
      converted = converter.convert_order_from_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_order_result_to_pb' do
    it 'converts OrderResult to Rpc::OrderResponse' do
      order_result = data_builder.new_order_result(
        data_builder.new_order(10))
      converted = converter.convert_order_result_to_pb(order_result)
      expect(converted.order_opened.pair_name).to eq 'EURJPY'
      expect(converted.order_opened.last_modified.seconds).to eq 10
      expect(converted.order_opened.last_modified.nanos).to eq 0
      expect(converted.order_opened.units).to eq 100_000
      expect(converted.trade_opened).to eq nil
      expect(converted.trade_reduced).to eq nil
      expect(converted.trades_closed).to eq []

      order_result = data_builder.new_order_result(
        nil, create_minimum_setting_order)
      converted = converter.convert_order_result_to_pb(order_result)
      expect(converted.order_opened).to eq nil
      expect(converted.trade_opened.pair_name).to eq 'USDJPY'
      expect(converted.trade_opened.last_modified.seconds).to eq 1_491_015_699
      expect(converted.trade_opened.last_modified.nanos).to eq 0
      expect(converted.trade_opened.units).to eq 0
      expect(converted.trade_reduced).to eq nil
      expect(converted.trades_closed).to eq []

      order_result = data_builder.new_order_result(
        nil, nil, data_builder.new_reduced_position(9, '2'), [
          data_builder.new_closed_position(10, '1'),
          data_builder.new_closed_position(30, '3', 10_000,
            100, Time.at(100), 12_031)
        ])
      converted = converter.convert_order_result_to_pb(order_result)
      expect(converted.order_opened).to eq nil
      expect(converted.trade_opened).to eq nil
      expect(converted.trade_reduced.internal_id).to eq '2'
      expect(converted.trade_reduced.units).to eq 9000
      expect(converted.trade_reduced.price.value).to eq '109.0'
      expect(converted.trade_reduced.timestamp.seconds).to eq 9
      expect(converted.trade_reduced.timestamp.nanos).to eq 0
      expect(converted.trade_reduced.profit_or_loss).to eq nil
      expect(converted.trades_closed.length).to eq 2
      expect(converted.trades_closed[0].internal_id).to eq '1'
      expect(converted.trades_closed[0].units).to eq 100_000
      expect(converted.trades_closed[0].price.value).to eq '110.0'
      expect(converted.trades_closed[0].timestamp.seconds).to eq 10
      expect(converted.trades_closed[0].timestamp.nanos).to eq 0
      expect(converted.trades_closed[0].profit_or_loss).to eq nil
      expect(converted.trades_closed[1].internal_id).to eq '3'
      expect(converted.trades_closed[1].units).to eq 10_000
      expect(converted.trades_closed[1].price.value).to eq '100.0'
      expect(converted.trades_closed[1].timestamp.seconds).to eq 100
      expect(converted.trades_closed[1].timestamp.nanos).to eq 0
      expect(converted.trades_closed[1].profit_or_loss.value).to eq '12031.0'
    end
    it 'returns nil when an order result is nil' do
      converted = converter.convert_order_result_to_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_order_options_from_pb' do
    it 'converts Rpc::OrderOption to order options' do
      option = Jiji::Rpc::OrderRequest::Option.new({
        lower_bound:   Jiji::Rpc::Decimal.new(value: '100'),
        upper_bound:   Jiji::Rpc::Decimal.new(value: '101'),
        stop_loss:     Jiji::Rpc::Decimal.new(value: '103'),
        take_profit:   Jiji::Rpc::Decimal.new(value: '104'),
        trailing_stop: 10,
        price:         Jiji::Rpc::Decimal.new(value: '105'),
        expiry:        Google::Protobuf::Timestamp.new(
          seconds: 100, nanos: 0)
      })
      converted = converter.convert_order_options_from_pb(option)
      expect(converted[:price]).to eq 105
      expect(converted[:expiry]).to eq Time.at(100)
      expect(converted[:lower_bound]).to eq 100
      expect(converted[:upper_bound]).to eq 101
      expect(converted[:stop_loss]).to eq 103
      expect(converted[:take_profit]).to eq 104
      expect(converted[:trailing_stop]).to eq 10

      option = Jiji::Rpc::OrderRequest::Option.new({})
      converted = converter.convert_order_options_from_pb(option)
      expect(converted[:price]).to eq nil
      expect(converted[:expiry]).to eq nil
      expect(converted[:lower_bound]).to eq nil
      expect(converted[:upper_bound]).to eq nil
      expect(converted[:stop_loss]).to eq nil
      expect(converted[:take_profit]).to eq nil
      expect(converted[:trailing_stop]).to eq nil
    end
    it 'returns nil when an order option is nil' do
      converted = converter.convert_order_options_from_pb(nil)
      expect(converted).to eq nil
    end
  end

  def create_order
    data_builder.new_order(10)
  end

  def create_minimum_setting_order
    Jiji::Model::Trading::Order.new(
      :USDJPY, '2', :sell, :limit, Time.new(2017, 4, 1, 12, 1, 39))
  end
end
