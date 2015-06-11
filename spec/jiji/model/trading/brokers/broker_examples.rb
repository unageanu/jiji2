
shared_examples 'brokerの基本操作ができる' do
  it 'rate,pairが取得できる' do
    pairs = broker.pairs
    expect(pairs.length).to eq 3
    expect(pairs[0].name).to eq :EURJPY
    expect(pairs[1].name).to eq :EURUSD
    expect(pairs[2].name).to eq :USDJPY

    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 135.3
    expect(rates[:EURJPY].ask).to eq 135.33

    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 135.3
    expect(rates[:EURJPY].ask).to eq 135.33

    broker.refresh
    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 135.56
    expect(rates[:EURJPY].ask).to eq 135.59
  end

  it '成行きで売り買いができる' do
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 0

    broker.tick
    expect(broker.next?).to eq true
    expect(broker.tick[:EURJPY].bid).to eq 135.30

    result = broker.buy(:EURJPY, 10_000)
    expected_position1 = Jiji::Model::Trading::Position.new do |p|
      p.backtest_id   = backtest_id
      p.internal_id   = result.trade_opened.internal_id
      p.pair_name     = :EURJPY
      p.units         = 10_000
      p.sell_or_buy   = :buy
      p.status        = :live
      p.entry_price   = 135.33
      p.entered_at    = Time.utc(2015, 5, 1)
      p.current_price = 135.30
      p.updated_at    = Time.utc(2015, 5, 1)
      p.exit_price    = nil
      p.exited_at     = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
      })
    end

    expect(broker.positions.length).to be 1
    expect(broker.positions[result.trade_opened.internal_id]) \
      .to some_position(expected_position1)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 1
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)

    broker.refresh
    expect(broker.next?).to eq true
    expect(broker.tick[:EURJPY].bid).to eq 135.56

    expected_position1.current_price = 135.56
    expected_position1.updated_at    = Time.utc(2015, 5, 1, 0, 0, 15)
    expect(broker.positions.length).to be 1
    expect(broker.positions[result.trade_opened.internal_id]) \
      .to some_position(expected_position1)

    result = broker.sell(:EURUSD, 10_000, :market)
    expected_position2 = Jiji::Model::Trading::Position.new do |p|
      p.backtest_id   = backtest_id
      p.internal_id   = result.trade_opened.internal_id
      p.pair_name     = :EURUSD
      p.units         = 10_000
      p.sell_or_buy   = :sell
      p.status        = :live
      p.entry_price   = 1.3834
      p.entered_at    = Time.utc(2015, 5, 1, 0, 0, 15)
      p.current_price = 1.3836
      p.updated_at    = Time.utc(2015, 5, 1, 0, 0, 15)
      p.exit_price    = nil
      p.exited_at     = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
      })
    end

    expect(broker.positions.length).to be 2
    expect(broker.positions[expected_position1.internal_id]) \
      .to some_position(expected_position1)
    expect(broker.positions[expected_position2.internal_id]) \
      .to some_position(expected_position2)

    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)

    buy_position = broker.positions[expected_position1.internal_id]
    broker.close_position(buy_position)

    expected_position1.status     = :closed
    expected_position1.exit_price = 135.56
    expected_position1.exited_at  = Time.utc(2015, 5, 1, 0, 0, 15)

    expect(buy_position).to some_position(expected_position1)

    expect(broker.positions.length).to be 1
    expect(broker.positions[expected_position2.internal_id]) \
      .to some_position(expected_position2)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)

    broker.refresh
    expect(broker.next?).to eq true

    expected_position2.current_price = 1.4236
    expected_position2.updated_at  = Time.utc(2015, 5, 1, 0, 0, 30)

    expect(broker.positions.length).to be 1
    expect(broker.positions[expected_position2.internal_id]) \
      .to some_position(expected_position2)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)

    broker.refresh

    expected_position2.current_price = 1.4266
    expected_position2.updated_at  = Time.utc(2015, 5, 1, 0, 0, 45)

    expect(broker.positions.length).to be 1
    expect(broker.positions[expected_position2.internal_id]) \
      .to some_position(expected_position2)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)

    broker.refresh
    expected_position2.current_price = 1.4246
    expected_position2.updated_at  = Time.utc(2015, 5, 1, 0, 1, 0)

    expect(broker.positions.length).to be 1
    expect(broker.positions[expected_position2.internal_id]) \
      .to some_position(expected_position2)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)

    broker.positions[expected_position2.internal_id].close
    broker.refresh
    expected_position2.status     = :closed
    expected_position2.exit_price = 1.4246
    expected_position2.exited_at  = Time.utc(2015, 5, 1, 0, 1, 0)

    expect(broker.positions.length).to be 0
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)

    broker.refresh

    expect(broker.positions.length).to be 0
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)
  end

  it '指値、逆指値、marketIfTouchedで売り買いができる' do
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 0

    broker.tick

    r1 = broker.sell(:EURJPY, 10_000, :limit, {
      price:       135.6,
      expiry:      Time.utc(2015, 5, 2),
      lower_bound: 135.59,
      upper_bound: 135.61,
      stop_loss:   135.73
    }).order_opened
    r2 = broker.buy(:USDJPY, 10_000, :stop, {
      price:       112.404,
      expiry:      Time.utc(2015, 5, 2),
      take_profit: 112.6
    }).order_opened
    r3 = broker.buy(:EURUSD, 10_000, :marketIfTouched, {
      price:         1.4325,
      expiry:        Time.utc(2015, 5, 2),
      trailing_stop: 5
    }).order_opened
    r4 = broker.sell(:EURJPY, 1000, :limit, {
      price:         136.6,
      expiry:        Time.utc(2015, 5, 1, 0, 0, 45),
      take_profit:   134,
      stop_loss:     140,
      trailing_stop: 10
    }).order_opened

    expected_order1 = Jiji::Model::Trading::Order.new(
      :EURJPY, r1.internal_id, :sell, :limit, Time.new(2015, 5, 1))
    expected_order1.units = 10_000
    expected_order1.price = 135.6
    expected_order1.expiry = Time.utc(2015, 5, 2)
    expected_order1.lower_bound = 135.59
    expected_order1.upper_bound = 135.61
    expected_order1.stop_loss = 135.73
    expected_order1.take_profit = 0
    expected_order1.trailing_stop = 0

    expected_order2 = Jiji::Model::Trading::Order.new(
      :USDJPY, r2.internal_id, :buy, :stop, Time.new(2015, 5, 1))
    expected_order2.units = 10_000
    expected_order2.price = 112.404
    expected_order2.expiry = Time.utc(2015, 5, 2)
    expected_order2.lower_bound = 0
    expected_order2.upper_bound = 0
    expected_order2.stop_loss = 0
    expected_order2.take_profit = 112.6
    expected_order2.trailing_stop = 0

    expected_order3 = Jiji::Model::Trading::Order.new(
      :EURUSD, r3.internal_id, :buy, :marketIfTouched, Time.new(2015, 5, 1))
    expected_order3.units = 10_000
    expected_order3.price = 1.4325
    expected_order3.expiry = Time.utc(2015, 5, 2)
    expected_order3.lower_bound = 0
    expected_order3.upper_bound = 0
    expected_order3.stop_loss = 0
    expected_order3.take_profit = 0
    expected_order3.trailing_stop = 5

    expected_order4 = Jiji::Model::Trading::Order.new(
      :EURJPY, r4.internal_id, :sell, :limit, Time.new(2015, 5, 1))
    expected_order4.units = 1000
    expected_order4.price = 136.6
    expected_order4.expiry = Time.utc(2015, 5, 1, 0, 0, 45)
    expected_order4.lower_bound = 0
    expected_order4.upper_bound = 0
    expected_order4.stop_loss = 140
    expected_order4.take_profit = 134
    expected_order4.trailing_stop = 10

    expect(sort_by_internal_id(broker.orders)).to eq([
      expected_order1, expected_order2, expected_order3, expected_order4
    ])
    positions = broker.positions
    expect(sort_by_internal_id(positions)).to eq([])
    positions = position_repository.retrieve_positions(backtest_id)
    expect(sort_by_internal_id(positions)).to eq([])

    broker.refresh_positions
    broker.refresh

    expect(sort_by_internal_id(broker.orders)).to eq([
      expected_order1, expected_order2, expected_order3, expected_order4
    ])
    positions = broker.positions
    expect(sort_by_internal_id(positions)).to eq([])
    positions = position_repository.retrieve_positions(backtest_id)
    expect(sort_by_internal_id(positions)).to eq([])

    broker.refresh_positions
    broker.refresh

    expect(sort_by_internal_id(broker.orders)).to eq([
      expected_order3, expected_order4
    ])

    expected_position1 = Jiji::Model::Trading::Position.new do |p|
      p.backtest_id   = backtest_id
      p.internal_id   = r1.internal_id
      p.pair_name     = :EURJPY
      p.units         = 10_000
      p.sell_or_buy   = :sell
      p.status        = :live
      p.entry_price   = 135.6
      p.entered_at    = Time.utc(2015, 5, 1, 0, 0, 30)
      p.current_price = 135.63
      p.updated_at    = Time.utc(2015, 5, 1, 0, 0, 30)
      p.exit_price    = nil
      p.exited_at     = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        stop_loss: 135.73
      })
    end
    expected_position2 = Jiji::Model::Trading::Position.new do |p|
      p.backtest_id   = backtest_id
      p.internal_id   = r2.internal_id
      p.pair_name     = :USDJPY
      p.units         = 10_000
      p.sell_or_buy   = :buy
      p.status        = :live
      p.entry_price   = 112.404
      p.entered_at    = Time.utc(2015, 5, 1, 0, 0, 30)
      p.current_price = 112.4
      p.updated_at    = Time.utc(2015, 5, 1, 0, 0, 30)
      p.exit_price    = nil
      p.exited_at     = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        take_profit: 112.6
      })
    end

    positions = broker.positions
    expect(positions.length).to be 2
    position = find_by_internal_id(positions, r1.internal_id)
    expect(position).to some_position(expected_position1)
    position = find_by_internal_id(positions, r2.internal_id)
    expect(position).to some_position(expected_position2)

    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    position = find_by_internal_id(positions, r1.internal_id)
    expect(position).to some_position(expected_position1)
    position = find_by_internal_id(positions, r2.internal_id)
    expect(position).to some_position(expected_position2)

    2.times do |_i|
      broker.refresh_positions
      broker.refresh
      tick = broker.tick

      expected_position1.current_price = tick[:EURJPY].ask
      expected_position1.updated_at    = tick.timestamp
      expected_position2.current_price = tick[:USDJPY].bid
      expected_position2.updated_at    = tick.timestamp

      expect(sort_by_internal_id(broker.orders)).to eq([
        expected_order3
      ])
      positions = broker.positions
      expect(positions.length).to be 2
      position = find_by_internal_id(positions, r1.internal_id)
      expect(position).to some_position(expected_position1)
      position = find_by_internal_id(positions, r2.internal_id)
      expect(position).to some_position(expected_position2)

      positions = position_repository.retrieve_positions(backtest_id)
      expect(positions.length).to be 2
      position = find_by_internal_id(positions, r1.internal_id)
      expect(position).to some_position(expected_position1)
      position = find_by_internal_id(positions, r2.internal_id)
      expect(position).to some_position(expected_position2)
    end

    broker.refresh_positions
    broker.refresh
    tick = broker.tick

    expected_position1.current_price = tick[:EURJPY].ask
    expected_position1.updated_at    = tick.timestamp
    expected_position1.exit_price    = tick[:EURJPY].ask
    expected_position1.exited_at     = tick.timestamp
    expected_position1.status        = :closed

    expected_position2.current_price = tick[:USDJPY].bid
    expected_position2.updated_at    = tick.timestamp

    expect(broker.orders).to eq([])

    expected_position3 = Jiji::Model::Trading::Position.new do |p|
      p.backtest_id   = backtest_id
      p.internal_id   = r3.internal_id
      p.pair_name     = :EURUSD
      p.units         = 10_000
      p.sell_or_buy   = :buy
      p.status        = :live
      p.entry_price   = 1.4325
      p.entered_at    = Time.utc(2015, 5, 1, 0, 1, 15)
      p.current_price = 1.5234
      p.updated_at    = Time.utc(2015, 5, 1, 0, 1, 15)
      p.exit_price    = nil
      p.exited_at     = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        trailing_stop:   5,
        trailing_amount: 1.5229
      })
    end

    positions = broker.positions
    expect(positions.length).to be 2
    position = find_by_internal_id(positions, r2.internal_id)
    expect(position).to some_position(expected_position2)
    position = find_by_internal_id(positions, r3.internal_id)
    expect(position).to some_position(expected_position3)

    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be
    position = find_by_internal_id(positions, r1.internal_id)
    expect(position).to some_position(expected_position1)
    position = find_by_internal_id(positions, r2.internal_id)
    expect(position).to some_position(expected_position2)
    position = find_by_internal_id(positions, r3.internal_id)
    expect(position).to some_position(expected_position3)

    positions = broker.positions
    position = find_by_internal_id(positions, r2.internal_id)
    position.close

    expected_position2.exit_price    = tick[:USDJPY].bid
    expected_position2.exited_at     = tick.timestamp
    expected_position2.status        = :closed

    positions = broker.positions
    expect(positions.length).to be 1
    position = find_by_internal_id(positions, r3.internal_id)
    expect(position).to some_position(expected_position3)

    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be
    position = find_by_internal_id(positions, r1.internal_id)
    expect(position).to some_position(expected_position1)
    position = find_by_internal_id(positions, r2.internal_id)
    expect(position).to some_position(expected_position2)
    position = find_by_internal_id(positions, r3.internal_id)
    expect(position).to some_position(expected_position3)

    broker.refresh_positions
    broker.refresh
    tick = broker.tick

    expected_position3.current_price = tick[:EURUSD].bid
    expected_position3.updated_at    = tick.timestamp
    expected_position3.closing_policy.trailing_amount = 1.5239

    orders = broker.orders
    expect(orders.length).to be 0

    positions = broker.positions
    expect(positions.length).to be 1
    position = find_by_internal_id(positions, r3.internal_id)
    expect(position).to some_position(expected_position3)

    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be
    position = find_by_internal_id(positions, r1.internal_id)
    expect(position).to some_position(expected_position1)
    position = find_by_internal_id(positions, r2.internal_id)
    expect(position).to some_position(expected_position2)
    position = find_by_internal_id(positions, r3.internal_id)
    expect(position).to some_position(expected_position3)
  end

  it '建玉を変更できる' do
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 0

    broker.tick

    result = broker.buy(:EURJPY, 10_000, :market, {
      stop_loss: 130
    })
    expected_position = Jiji::Model::Trading::Position.new do |p|
      p.backtest_id   = backtest_id
      p.internal_id   = result.trade_opened.internal_id
      p.pair_name     = :EURJPY
      p.units         = 10_000
      p.sell_or_buy   = :buy
      p.status        = :live
      p.entry_price   = 135.33
      p.entered_at    = Time.utc(2015, 5, 1)
      p.current_price = 135.30
      p.updated_at    = Time.utc(2015, 5, 1)
      p.exit_price    = nil
      p.exited_at     = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        stop_loss: 130
      })
    end

    expect(broker.positions.length).to be 1
    expect(broker.positions[result.trade_opened.internal_id]) \
      .to some_position(expected_position)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 1
    expect(find_by_internal_id(positions, expected_position.internal_id)) \
      .to some_position(expected_position)

    position = broker.positions[result.trade_opened.internal_id]
    position.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
      stop_loss:     130,
      take_profit:   140.5,
      trailing_stop: 10
    })
    position.modify

    expected_position.closing_policy = position.closing_policy
    expect(broker.positions[result.trade_opened.internal_id]) \
      .to some_position(expected_position)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 1
    expect(find_by_internal_id(positions, expected_position.internal_id)) \
      .to some_position(expected_position)

    position = broker.positions[result.trade_opened.internal_id]
    position.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
      stop_loss:     130.01,
      take_profit:   0,
      trailing_stop: 0
    })
    broker.modify_position(position)

    expected_position.closing_policy = position.closing_policy
    expect(broker.positions[result.trade_opened.internal_id]) \
      .to some_position(expected_position)
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 1
    expect(find_by_internal_id(positions, expected_position.internal_id)) \
      .to some_position(expected_position)
  end

  it '注文の変更ができる' do
    broker.tick

    result = broker.sell(:EURJPY, 10_000, :limit, {
      price:       135.6,
      expiry:      Time.utc(2015, 5, 2),
      lower_bound: 135.59,
      upper_bound: 135.61,
      stop_loss:   135.73
    }).order_opened

    expected_order = Jiji::Model::Trading::Order.new(
      :EURJPY, result.internal_id, :sell, :limit, Time.new(2015, 5, 1))
    expected_order.units = 10_000
    expected_order.price = 135.6
    expected_order.expiry = Time.utc(2015, 5, 2)
    expected_order.lower_bound = 135.59
    expected_order.upper_bound = 135.61
    expected_order.stop_loss = 135.73
    expected_order.take_profit = 0
    expected_order.trailing_stop = 0

    order = find_by_internal_id(broker.orders, result.internal_id)
    expect(order).to eq(expected_order)

    order.price = 135.7
    order.expiry = Time.utc(2015, 5, 3)
    order.lower_bound = 135.69
    order.upper_bound = 135.71
    order.stop_loss = 135.83
    order.take_profit = 135.63
    order.trailing_stop = 10

    broker.modify_order(order)

    expected_order.price = 135.7
    expected_order.expiry = Time.utc(2015, 5, 3)
    expected_order.lower_bound = 135.69
    expected_order.upper_bound = 135.71
    expected_order.stop_loss = 135.83
    expected_order.take_profit = 135.63
    expected_order.trailing_stop = 10

    order = find_by_internal_id(broker.orders, result.internal_id)
    expect(order).to eq(expected_order)

    order.expiry = Time.utc(2015, 5, 4)
    order.modify

    expected_order.expiry = Time.utc(2015, 5, 4)

    order = find_by_internal_id(broker.orders, result.internal_id)
    expect(order).to eq(expected_order)
  end

  it '注文のキャンセルができる' do
    broker.tick

    result1 = broker.sell(:EURJPY, 10_000, :limit, {
      price:  135.6,
      expiry: Time.utc(2015, 5, 2)
    }).order_opened

    result2 = broker.buy(:EURJPY, 10_000, :limit, {
      price:  134.6,
      expiry: Time.utc(2015, 5, 2)
    }).order_opened

    expect(broker.orders.length).to be 2

    order = find_by_internal_id(broker.orders, result1.internal_id)
    cancel_result = broker.cancel_order(order)
    expect(cancel_result).to eq order

    expect(broker.orders.length).to be 1

    order = find_by_internal_id(broker.orders, result2.internal_id)
    cancel_result = order.cancel
    expect(cancel_result).to eq order

    expect(broker.orders.length).to be 0
  end

  it '破棄操作ができる' do
    broker.destroy
  end

  def sort_by_internal_id(orders_or_positions)
    orders_or_positions.sort_by { |o| o.internal_id }
  end

  def find_by_internal_id(orders_or_positions, internal_id)
    orders_or_positions.find { |o| o.internal_id == internal_id }
  end
end
