# frozen_string_literal: true

require 'jiji/test/test_configuration'

require 'jiji/model/securities/internal/examples/ordering_examples'
require 'jiji/model/securities/internal' \
        + '/examples/ordering_response_pattern_examples'

if ENV['OANDA_API_ACCESS_TOKEN']
  describe Jiji::Model::Securities::Internal::Virtual::Ordering do
    include_context 'use backtests'
    let(:wait) { 0 }
    let(:backtest_id) { backtests[0].id }
    let(:client) do
      Jiji::Test::VirtualSecuritiesBuilder.build(
        Time.utc(2015, 4, 1), Time.utc(2015, 4, 1, 6), backtest_id)
    end
    let(:position_repository) do
      container.lookup(:position_repository)
    end

    it_behaves_like '注文関連の操作'
    #it_behaves_like '注文関連の操作(建玉がある場合のバリエーションパターン)'

    it 'レート更新時に、注文が条件を満たすと約定する' do
      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0

      tick = client.retrieve_current_tick
      now  = tick.timestamp

      order1 = client.order(:EURJPY, :sell, 1, :limit, {
        price:         128.9,
        time_in_force: "GTD",
        gtd_time:      now + (60 * 60 * 24),
        trailing_stop_loss_on_fill: {
          distance: 10
        }
      }).order_opened
      order2 = client.order(:USDJPY, :buy, 10, :stop, {
        price:         120,
        time_in_force: "GTD",
        gtd_time:      now + (60 * 60 * 24),
        stop_loss_on_fill: {
          price: 119
        },
        take_profit_on_fill: {
          price: 121
        }
      }).order_opened
      order3 = client.order(:EURJPY, :sell, 2, :marketIfTouched, {
        price:         128.9,
        time_in_force: "GTD",
        gtd_time:      now + (60 * 60 * 24),
      }).order_opened
      order4 = client.order(:EURJPY, :sell, 3, :limit, {
        price:         128.9,
        time_in_force: "GTD",
        gtd_time:      now + 45,
      }).order_opened

      orders = client.retrieve_orders
      expect(orders.length).to be 4

      order = orders.find { |o| o.internal_id == order1.internal_id }
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 1
      expect(order.type).to be :limit
      expect(order.price).to eq(128.9)

      order = orders.find { |o| o.internal_id == order2.internal_id }
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :stop
      expect(order.price).to eq(120)

      order = orders.find { |o| o.internal_id == order3.internal_id }
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(128.9)

      order = orders.find { |o| o.internal_id == order4.internal_id }
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 3
      expect(order.type).to be :limit
      expect(order.price).to eq(128.9)

      2.times do
        client.retrieve_current_tick
        expect(client.retrieve_orders.length).to be 4
        expect(client.retrieve_trades.length).to be 0
      end

      client.retrieve_current_tick
      orders = client.retrieve_orders
      expect(orders.length).to be 3

      order = orders.find { |o| o.internal_id == order4.internal_id }
      expect(order).to be nil

      5.times do
        client.retrieve_current_tick
        expect(client.retrieve_orders.length).to be 3
        expect(client.retrieve_trades.length).to be 0
      end

      rates1 = client.retrieve_current_tick
      orders = client.retrieve_orders
      expect(orders.length).to be 2
      order = orders.find { |o| o.internal_id == order2.internal_id }
      expect(order).to be nil

      positions = client.retrieve_trades
      expect(positions.length).to be 1

      position = positions.find { |o| o.internal_id == order2.internal_id }
      expect(position.pair_name).to eq :USDJPY
      expect(position.units).to eq 10
      expect(position.sell_or_buy).to eq :buy
      expect(position.status).to eq :live
      expect(position.entry_price).to eq 120
      expect(position.entered_at).not_to be rates1.timestamp
      expect(position.current_price).to eq rates1[:USDJPY].bid
      expect(position.updated_at).not_to be rates1.timestamp
      expect(position.closing_policy.stop_loss).to eq(119)
      expect(position.closing_policy.take_profit).to eq(121)
      expect(position.closing_policy.trailing_stop).to eq(0)
      expect(position.closing_policy.trailing_amount).to eq(0)

      44.times do
        client.retrieve_current_tick
        expect(client.retrieve_orders.length).to be 2
        expect(client.retrieve_trades.length).to be 1
      end

      rates2 = client.retrieve_current_tick
      orders = client.retrieve_orders
      expect(orders.length).to be 0

      positions = client.retrieve_trades
      expect(positions.length).to be 3

      position = positions.find { |o| o.internal_id == order2.internal_id }
      expect(position.pair_name).to eq :USDJPY
      expect(position.units).to eq 10
      expect(position.sell_or_buy).to eq :buy
      expect(position.status).to eq :live
      expect(position.entry_price).to eq 120
      expect(position.entered_at).not_to be rates1.timestamp
      expect(position.current_price).to eq rates2[:USDJPY].bid
      expect(position.updated_at).not_to be rates2.timestamp
      expect(position.closing_policy.stop_loss).to eq(119)
      expect(position.closing_policy.take_profit).to eq(121)
      expect(position.closing_policy.trailing_stop).to eq(0)
      expect(position.closing_policy.trailing_amount).to eq(0)

      position = positions.find { |o| o.internal_id == order1.internal_id }
      expect(position.pair_name).to eq :EURJPY
      expect(position.units).to eq 1
      expect(position.sell_or_buy).to eq :sell
      expect(position.status).to eq :live
      expect(position.entry_price).to eq 128.9
      expect(position.entered_at).not_to be rates2.timestamp
      expect(position.current_price).to eq rates2[:EURJPY].ask
      expect(position.updated_at).not_to be rates2.timestamp
      expect(position.closing_policy.stop_loss).to eq(0)
      expect(position.closing_policy.take_profit).to eq(0)
      expect(position.closing_policy.trailing_stop).to eq(10)
      expect(position.closing_policy.trailing_amount).to eq(129.031)

      position = positions.find { |o| o.internal_id == order3.internal_id }
      expect(position.pair_name).to eq :EURJPY
      expect(position.units).to eq 2
      expect(position.sell_or_buy).to eq :sell
      expect(position.status).to eq :live
      expect(position.entry_price).to eq 128.9
      expect(position.entered_at).not_to be rates2.timestamp
      expect(position.current_price).to eq rates2[:EURJPY].ask
      expect(position.updated_at).not_to be rates2.timestamp
      expect(position.closing_policy.stop_loss).to eq(0)
      expect(position.closing_policy.take_profit).to eq(0)
      expect(position.closing_policy.trailing_stop).to eq(0)
      expect(position.closing_policy.trailing_amount).to eq(0)

      rates3 = client.retrieve_current_tick
      orders = client.retrieve_orders
      expect(orders.length).to be 0

      positions = client.retrieve_trades
      expect(positions.length).to be 3

      position = positions.find { |o| o.internal_id == order2.internal_id }
      expect(position.pair_name).to eq :USDJPY
      expect(position.units).to eq 10
      expect(position.sell_or_buy).to eq :buy
      expect(position.status).to eq :live
      expect(position.entry_price).to eq 120
      expect(position.entered_at).not_to be rates1.timestamp
      expect(position.current_price).to eq rates3[:USDJPY].bid
      expect(position.updated_at).not_to be rates3.timestamp
      expect(position.closing_policy.stop_loss).to eq(119)
      expect(position.closing_policy.take_profit).to eq(121)
      expect(position.closing_policy.trailing_stop).to eq(0)
      expect(position.closing_policy.trailing_amount).to eq(0)

      position = positions.find { |o| o.internal_id == order1.internal_id }
      expect(position.pair_name).to eq :EURJPY
      expect(position.units).to eq 1
      expect(position.sell_or_buy).to eq :sell
      expect(position.status).to eq :live
      expect(position.entry_price).to eq 128.9
      expect(position.entered_at).not_to be rates2.timestamp
      expect(position.current_price).to eq rates3[:EURJPY].ask
      expect(position.updated_at).not_to be rates3.timestamp
      expect(position.closing_policy.stop_loss).to eq(0)
      expect(position.closing_policy.take_profit).to eq(0)
      expect(position.closing_policy.trailing_stop).to eq(10)
      expect(position.closing_policy.trailing_amount).to eq(129.031)

      position = positions.find { |o| o.internal_id == order3.internal_id }
      expect(position.pair_name).to eq :EURJPY
      expect(position.units).to eq 2
      expect(position.sell_or_buy).to eq :sell
      expect(position.status).to eq :live
      expect(position.entry_price).to eq 128.9
      expect(position.entered_at).not_to be rates2.timestamp
      expect(position.current_price).to eq rates3[:EURJPY].ask
      expect(position.updated_at).not_to be rates3.timestamp
      expect(position.closing_policy.stop_loss).to eq(0)
      expect(position.closing_policy.take_profit).to eq(0)
      expect(position.closing_policy.trailing_stop).to eq(0)
      expect(position.closing_policy.trailing_amount).to eq(0)

      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0
    end
  end
end
