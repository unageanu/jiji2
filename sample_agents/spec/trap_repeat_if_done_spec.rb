# coding: utf-8

require 'sample_agent_test_configuration'

describe TrapRepeatIfDone do
  include_context 'use agent_setting'

  let(:position_repository) { container.lookup(:position_repository) }
  let(:backtest) { backtests[0] }
  let(:mock_securities) do
    Jiji::Test::Mock::MockSecurities.new({})
  end
  let(:securities_provider) do
    securities_provider = Jiji::Model::Securities::SecuritiesProvider.new
    securities_provider.set mock_securities
    securities_provider
  end
  let(:tick_repository) do
    repository = Jiji::Model::Trading::TickRepository.new
    repository.securities_provider = securities_provider
    repository
  end
  let(:pairs) do
    [
      Jiji::Model::Trading::Pair.new(
        :EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
      Jiji::Model::Trading::Pair.new(
        :EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04),
      Jiji::Model::Trading::Pair.new(
        :USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
    ]
  end
  let(:broker) do
    broker = Jiji::Model::Trading::Brokers::BackTestBroker.new(backtest,
      Time.utc(2015, 5, 1), Time.utc(2015, 5, 1, 0, 10), pairs, 100_000, [], {
        tick_repository:     tick_repository,
        securities_provider: securities_provider,
        position_repository: position_repository
      })
    Jiji::Model::Trading::Brokers::BrokerProxy.new(broker, nil)
  end

  describe 'EURJPY/買モード/スリッページありの場合' do
    let(:logic) do
      TrapRepeatIfDone.new(pairs[0], :buy, 40, 10, 80, 3, Logger.new(STDOUT))
    end

    it '注文を登録できる' do
      mock_securities.seeds = [0, 0.25, 0.41, 0.5]

      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      order = orders[0]
      expect(orders.length).to eq 6
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(134.4)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(134.37)
      expect(order.upper_bound).to eq(134.43)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(135.2)
      expect(order.trailing_stop).to eq 0

      order = orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(134.8)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(134.77)
      expect(order.upper_bound).to eq(134.83)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(135.6)
      expect(order.trailing_stop).to eq 0

      order = orders[2]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(135.2)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.17)
      expect(order.upper_bound).to eq(135.23)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.0)
      expect(order.trailing_stop).to eq 0

      order = orders[3]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(135.6)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.57)
      expect(order.upper_bound).to eq(135.63)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.4)
      expect(order.trailing_stop).to eq 0

      order = orders[4]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.0)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.97)
      expect(order.upper_bound).to eq(136.03)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.8)
      expect(order.trailing_stop).to eq 0

      order = orders[5]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.4)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(136.37)
      expect(order.upper_bound).to eq(136.43)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(137.2)
      expect(order.trailing_stop).to eq 0

      prev = orders

      # 同じ価格で再度呼び出しても新しい注文は登録されない
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end

      # baseが変化しない場合も、新しい注文は登録されない
      broker.refresh
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end

      # baseが変化すると、新しい注文が登録される
      broker.refresh
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6

      order = orders[0]
      expect(order.internal_id).to be prev[0].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(134.4)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(134.37)
      expect(order.upper_bound).to eq(134.43)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(135.2)
      expect(order.trailing_stop).to eq 0

      order = orders[1]
      expect(order.internal_id).to be prev[1].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(134.8)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(134.77)
      expect(order.upper_bound).to eq(134.83)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(135.6)
      expect(order.trailing_stop).to eq 0

      order = orders[2]
      expect(order.internal_id).to be prev[2].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(135.2)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.17)
      expect(order.upper_bound).to eq(135.23)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.0)
      expect(order.trailing_stop).to eq 0

      order = orders[3]
      expect(order.internal_id).to be prev[4].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.0)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.97)
      expect(order.upper_bound).to eq(136.03)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.8)
      expect(order.trailing_stop).to eq 0

      order = orders[4]
      expect(order.internal_id).to be prev[5].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.4)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(136.37)
      expect(order.upper_bound).to eq(136.43)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(137.2)
      expect(order.trailing_stop).to eq 0

      order = orders[5]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.8)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(136.77)
      expect(order.upper_bound).to eq(136.83)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(137.6)
      expect(order.trailing_stop).to eq 0

      expect(broker.positions.length).to be 1

      prev = orders

      broker.refresh
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end

      # 建玉を決済すると、注文が再登録される
      broker.positions.each { |p| p.close }
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 7

      order = orders[0]
      expect(order.internal_id).to be prev[0].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(134.4)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(134.37)
      expect(order.upper_bound).to eq(134.43)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(135.2)
      expect(order.trailing_stop).to eq 0

      order = orders[1]
      expect(order.internal_id).to be prev[1].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(134.8)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(134.77)
      expect(order.upper_bound).to eq(134.83)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(135.6)
      expect(order.trailing_stop).to eq 0

      order = orders[2]
      expect(order.internal_id).to be prev[2].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(135.2)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.17)
      expect(order.upper_bound).to eq(135.23)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.0)
      expect(order.trailing_stop).to eq 0

      order = orders[3]
      expect(order.internal_id).to be prev[3].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.0)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.97)
      expect(order.upper_bound).to eq(136.03)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.8)
      expect(order.trailing_stop).to eq 0

      order = orders[4]
      expect(order.internal_id).to be prev[4].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.4)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(136.37)
      expect(order.upper_bound).to eq(136.43)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(137.2)
      expect(order.trailing_stop).to eq 0

      order = orders[5]
      expect(order.internal_id).to be prev[5].internal_id
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(136.8)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(136.77)
      expect(order.upper_bound).to eq(136.83)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(137.6)
      expect(order.trailing_stop).to eq 0

      order = orders[6]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 10
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(135.6)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to eq(135.57)
      expect(order.upper_bound).to eq(135.63)
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(136.4)
      expect(order.trailing_stop).to eq 0

      expect(broker.positions.length).to be 0

      prev = orders

      # state/restore_state
      state = logic.state
      logic = TrapRepeatIfDone.new(pairs[0],
        :buy, 40, 10, 80, 3, Logger.new(STDOUT))
      logic.restore_state(state)

      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 7
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end
    end
  end

  describe 'EURUSD/売りモード/スリッページなしの場合' do
    let(:logic) do
      TrapRepeatIfDone.new(pairs[1], :sell, 55, 8, 103, nil, Logger.new(STDOUT))
    end

    it '注文を登録できる' do
      mock_securities.seeds = [0, 0.003, 0.0045, 0.0056]

      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      order = orders[0]
      expect(orders.length).to eq 6
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1110)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1007)
      expect(order.trailing_stop).to eq 0

      order = orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1165)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1062)
      expect(order.trailing_stop).to eq 0

      order = orders[2]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1220)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1117)
      expect(order.trailing_stop).to eq 0

      order = orders[3]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1275)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1172)
      expect(order.trailing_stop).to eq 0

      order = orders[4]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1330)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1227)
      expect(order.trailing_stop).to eq 0

      order = orders[5]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1385)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1282)
      expect(order.trailing_stop).to eq 0

      prev = orders

      # 同じ価格で再度呼び出しても新しい注文は登録されない
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end

      # baseが変化しない場合も、新しい注文は登録されない
      broker.refresh
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end

      # baseが変化すると、新しい注文が登録される
      broker.refresh
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6

      order = orders[0]
      expect(order.internal_id).to be prev[0].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1110)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1007)
      expect(order.trailing_stop).to eq 0

      order = orders[1]
      expect(order.internal_id).to be prev[1].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1165)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1062)
      expect(order.trailing_stop).to eq 0

      order = orders[2]
      expect(order.internal_id).to be prev[2].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1220)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1117)
      expect(order.trailing_stop).to eq 0

      order = orders[3]
      expect(order.internal_id).to be prev[4].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1330)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1227)
      expect(order.trailing_stop).to eq 0

      order = orders[4]
      expect(order.internal_id).to be prev[5].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1385)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1282)
      expect(order.trailing_stop).to eq 0

      order = orders[5]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1440)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1337)
      expect(order.trailing_stop).to eq 0

      expect(broker.positions.length).to be 1

      prev = orders

      broker.refresh
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 6
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end

      # 建玉を決済すると、注文が再登録される
      broker.positions.each { |p| p.close }
      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 7

      order = orders[0]
      expect(order.internal_id).to be prev[0].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1110)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1007)
      expect(order.trailing_stop).to eq 0

      order = orders[1]
      expect(order.internal_id).to be prev[1].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1165)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1062)
      expect(order.trailing_stop).to eq 0

      order = orders[2]
      expect(order.internal_id).to be prev[2].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1220)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1117)
      expect(order.trailing_stop).to eq 0

      order = orders[3]
      expect(order.internal_id).to be prev[3].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1330)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1227)
      expect(order.trailing_stop).to eq 0

      order = orders[4]
      expect(order.internal_id).to be prev[4].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1385)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1282)
      expect(order.trailing_stop).to eq 0

      order = orders[5]
      expect(order.internal_id).to be prev[5].internal_id
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1440)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1337)
      expect(order.trailing_stop).to eq 0

      order = orders[6]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURUSD
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 8
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq(1.1275)
      expect(order.expiry).not_to eq nil
      expect(order.lower_bound).to be 0
      expect(order.upper_bound).to be 0
      expect(order.stop_loss).to be 0
      expect(order.take_profit).to eq(1.1172)
      expect(order.trailing_stop).to eq 0

      expect(broker.positions.length).to be 0

      prev = orders

      # state/restore_state
      state = logic.state
      logic = TrapRepeatIfDone.new(pairs[1],
        :sell, 55, 8, 103, nil, Logger.new(STDOUT))
      logic.restore_state(state)

      logic.register_orders(broker)

      orders = broker.orders.sort_by { |o| o.internal_id }
      expect(orders.length).to eq 7
      orders.length.times do |i|
        expect(orders[i]).to some_order(prev[i])
      end
    end
  end

  def new_tick_value(bid, spread)
    Jiji::Model::Trading::Tick::Value.new(
      bid, BigDecimal.new(bid, 10) + spread)
  end

  def restart(manager, notificator)
    state = manager.state
    manager = TrailingStopManager.new(10, 20, notificator)
    manager.restore_state(state)
    manager
  end
end
