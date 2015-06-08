# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/internal/examples/trading_examples'

describe Jiji::Model::Securities::Internal::Virtual::Trading do
  let(:wait) { 0 }
  let(:container) do
    Jiji::Test::TestContainerFactory.instance.new_container
  end
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:backtest_id) do
    backtest_repository  = container.lookup(:backtest_repository)
    registory            = container.lookup(:agent_registry)

    registory.add_source('aaa', '', :agent, data_builder.new_agent_body(1))

    data_builder.register_backtest(1, backtest_repository).id
  end
  let(:client) do
    Jiji::Test::VirtualSecuritiesBuilder.build(
      Time.utc(2015, 4, 1), Time.utc(2015, 4, 1, 6), backtest_id)
  end
  let(:position_repository) do
    container.lookup(:position_repository)
  end

  after(:example) do
    data_builder.clean
  end

  it_behaves_like '建玉関連の操作'

  it 'レート更新時に、建玉が決済条件を満たすと決済される' do
    saved_positions = position_repository.retrieve_positions(backtest_id)
    expect(saved_positions.length).to be 0

    rates1 = client.retrieve_current_tick

    order1 = client.order(:EURJPY, :sell, 1, :market, {
      stop_loss: 128.9
    }).trade_opened
    order2 = client.order(:USDJPY, :buy, 10, :market, {
      take_profit: 119.97
    }).trade_opened
    order3 = client.order(:EURJPY, :sell, 2, :market, {
      trailing_stop: 10
    }).trade_opened

    positions = client.retrieve_trades
    expect(positions.length).to be 3

    position = positions.find { |o| o.internal_id == order1.internal_id }
    expect(position.pair_name).to eq :EURJPY
    expect(position.units).to eq 1
    expect(position.sell_or_buy).to eq :sell
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:EURJPY].bid
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates1[:EURJPY].ask
    expect(position.updated_at).not_to be rates1.timestamp
    expect(position.closing_policy.stop_loss).to eq(128.9)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(0)
    expect(position.closing_policy.trailing_amount).to eq(0)

    position = positions.find { |o| o.internal_id == order2.internal_id }
    expect(position.pair_name).to eq :USDJPY
    expect(position.units).to eq 10
    expect(position.sell_or_buy).to eq :buy
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:USDJPY].ask
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates1[:USDJPY].bid
    expect(position.updated_at).not_to be rates1.timestamp
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.take_profit).to eq(119.97)
    expect(position.closing_policy.trailing_stop).to eq(0)
    expect(position.closing_policy.trailing_amount).to eq(0)

    position = positions.find { |o| o.internal_id == order3.internal_id }
    expect(position.pair_name).to eq :EURJPY
    expect(position.units).to eq 2
    expect(position.sell_or_buy).to eq :sell
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:EURJPY].bid
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates1[:EURJPY].ask
    expect(position.updated_at).not_to be rates1.timestamp
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(10)
    expect(position.closing_policy.trailing_amount).to eq(0)

    rates2 = client.retrieve_current_tick
    positions = client.retrieve_trades
    expect(positions.length).to be 3

    position = positions.find { |o| o.internal_id == order1.internal_id }
    expect(position.pair_name).to eq :EURJPY
    expect(position.units).to eq 1
    expect(position.sell_or_buy).to eq :sell
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:EURJPY].bid
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates2[:EURJPY].ask
    expect(position.updated_at).not_to be rates2.timestamp
    expect(position.closing_policy.stop_loss).to eq(128.9)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(0)
    expect(position.closing_policy.trailing_amount).to eq(0)

    position = positions.find { |o| o.internal_id == order2.internal_id }
    expect(position.pair_name).to eq :USDJPY
    expect(position.units).to eq 10
    expect(position.sell_or_buy).to eq :buy
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:USDJPY].ask
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates2[:USDJPY].bid
    expect(position.updated_at).not_to be rates2.timestamp
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.take_profit).to eq(119.97)
    expect(position.closing_policy.trailing_stop).to eq(0)
    expect(position.closing_policy.trailing_amount).to eq(0)

    position = positions.find { |o| o.internal_id == order3.internal_id }
    expect(position.pair_name).to eq :EURJPY
    expect(position.units).to eq 2
    expect(position.sell_or_buy).to eq :sell
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:EURJPY].bid
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates2[:EURJPY].ask
    expect(position.updated_at).not_to be rates2.timestamp
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(10)
    expect(position.closing_policy.trailing_amount).to eq(128.946)

    3.times do |_i|
      client.retrieve_current_tick
      positions = client.retrieve_trades
      expect(positions.length).to be 3
    end

    rates2 = client.retrieve_current_tick
    positions = client.retrieve_trades
    expect(positions.length).to be 2

    position = positions.find { |o| o.internal_id == order1.internal_id }
    expect(position.pair_name).to eq :EURJPY
    expect(position.units).to eq 1
    expect(position.sell_or_buy).to eq :sell
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:EURJPY].bid
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates2[:EURJPY].ask
    expect(position.updated_at).not_to be rates2.timestamp
    expect(position.closing_policy.stop_loss).to eq(128.9)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(0)
    expect(position.closing_policy.trailing_amount).to eq(0)

    position = positions.find { |o| o.internal_id == order2.internal_id }
    expect(position).to be nil

    position = positions.find { |o| o.internal_id == order3.internal_id }
    expect(position.pair_name).to eq :EURJPY
    expect(position.units).to eq 2
    expect(position.sell_or_buy).to eq :sell
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:EURJPY].bid
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates2[:EURJPY].ask
    expect(position.updated_at).not_to be rates2.timestamp
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(10)
    expect(position.closing_policy.trailing_amount).to eq(128.944)

    3.times do |_i|
      client.retrieve_current_tick
      positions = client.retrieve_trades
      expect(positions.length).to be 2
    end

    rates2 = client.retrieve_current_tick
    positions = client.retrieve_trades
    expect(positions.length).to be 1

    position = positions.find { |o| o.internal_id == order1.internal_id }
    expect(position).to be nil

    position = positions.find { |o| o.internal_id == order2.internal_id }
    expect(position).to be nil

    position = positions.find { |o| o.internal_id == order3.internal_id }
    expect(position.pair_name).to eq :EURJPY
    expect(position.units).to eq 2
    expect(position.sell_or_buy).to eq :sell
    expect(position.status).to eq :live
    expect(position.entry_price).to eq rates1[:EURJPY].bid
    expect(position.entered_at).not_to be rates1.timestamp
    expect(position.current_price).to eq rates2[:EURJPY].ask
    expect(position.updated_at).not_to be rates2.timestamp
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(10)
    expect(position.closing_policy.trailing_amount).to eq(128.944)

    92.times do |_i|
      client.retrieve_current_tick
      positions = client.retrieve_trades
      expect(positions.length).to be 1
    end

    client.retrieve_current_tick
    positions = client.retrieve_trades
    expect(positions.length).to be 0

    saved_positions = position_repository.retrieve_positions(backtest_id)
    expect(saved_positions.length).to be 0
  end
end
