
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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    broker.tick
    expect(broker.next?).to eq true
    expect(broker.tick[:EURJPY].bid).to eq 135.30

    result = broker.buy(:EURJPY, 10_000)
    expected_position1 = Jiji::Model::Trading::Position.new do |p|
      p.backtest      = backtest
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
      p.agent_id      = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({})
      p.current_counter_rate = 1
    end

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq(-300)
    expect(broker.account.margin_used).to eq 54_120.0

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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 2300
    expect(broker.account.margin_used).to eq 54_224.0

    expected_position1.current_price = 135.56
    expected_position1.updated_at    = Time.utc(2015, 5, 1, 0, 0, 15)
    expected_position1.update_profit_or_loss
    expect(broker.positions.length).to be 1
    expect(broker.positions[result.trade_opened.internal_id]) \
      .to some_position(expected_position1)

    result = broker.sell(:EURUSD, 10_000, :market, {}, agent_setting.id)
    expected_position2 = Jiji::Model::Trading::Position.new do |p|
      p.backtest      = backtest
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
      p.agent_id      = agent_setting.id
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
      })
      p.current_counter_rate = 112.37
    end

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 2075.26
    expect(broker.account.margin_used).to eq 54_777.44

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

    expect(broker.account.balance).to eq 102_300
    expect(broker.account.profit_or_loss).to eq(-224.74)
    expect(broker.account.margin_used.to_f).to eq 553.44

    expected_position1.status     = :closed
    expected_position1.exit_price = 135.56
    expected_position1.exited_at  = Time.utc(2015, 5, 1, 0, 0, 15)
    expected_position1.update_profit_or_loss

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

    expect(broker.account.balance).to eq 102_300
    expect(broker.account.profit_or_loss).to eq(-45_188.82)
    expect(broker.account.margin_used.to_f).to eq 569.44

    expected_position2.current_price = 1.4236
    expected_position2.current_counter_rate = 112.41
    expected_position2.updated_at = Time.utc(2015, 5, 1, 0, 0, 30)
    expected_position2.update_profit_or_loss

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

    expect(broker.account.balance).to eq 102_300
    expect(broker.account.profit_or_loss).to eq(-48_562.416)
    expect(broker.account.margin_used.to_f).to eq 570.64

    expected_position2.current_price = 1.4266
    expected_position2.current_counter_rate = 112.413
    expected_position2.updated_at = Time.utc(2015, 5, 1, 0, 0, 45)
    expected_position2.update_profit_or_loss

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

    expect(broker.account.balance).to eq 102_300
    expect(broker.account.profit_or_loss).to eq(-46_313.332)
    expect(broker.account.margin_used.to_f).to eq 569.84

    expected_position2.current_price = 1.4246
    expected_position2.current_counter_rate = 112.411
    expected_position2.updated_at = Time.utc(2015, 5, 1, 0, 1, 0)
    expected_position2.update_profit_or_loss

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

    expect(broker.account.balance).to eq 55_986.668
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    broker.refresh

    expect(broker.account.balance).to eq 55_986.668
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    expected_position2.status     = :closed
    expected_position2.exit_price = 1.4246
    expected_position2.exited_at  = Time.utc(2015, 5, 1, 0, 1, 0)
    expected_position2.update_profit_or_loss

    expect(broker.positions.length).to be 0
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 2
    expect(find_by_internal_id(positions, expected_position1.internal_id)) \
      .to some_position(expected_position1)
    expect(find_by_internal_id(positions, expected_position2.internal_id)) \
      .to some_position(expected_position2)

    broker.refresh

    expect(broker.account.balance).to eq 55_986.668
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    broker.tick

    r1 = broker.sell(:EURJPY, 10_000, :limit, {
      price:       135.6,
      expiry:      Time.utc(2015, 5, 2),
      lower_bound: 135.59,
      upper_bound: 135.61,
      stop_loss:   135.73
    }, agent_setting.id).order_opened
    r2 = broker.buy(:USDJPY, 10_000, :stop, {
      price:       112.404,
      expiry:      Time.utc(2015, 5, 2),
      take_profit: 112.6
    }, agent_setting.id).order_opened
    r3 = broker.buy(:EURUSD, 10_000, :marketIfTouched, {
      price:         1.4325,
      expiry:        Time.utc(2015, 5, 2),
      trailing_stop: 5
    }, agent_setting.id).order_opened
    r4 = broker.sell(:EURJPY, 1000, :limit, {
      price:         136.6,
      expiry:        Time.utc(2015, 5, 1, 0, 0, 45),
      take_profit:   134,
      stop_loss:     140,
      trailing_stop: 10
    }, agent_setting.id).order_opened

    expected_order1 = Jiji::Model::Trading::Order.new(
      :EURJPY, r1.internal_id, :sell, :limit, Time.utc(2015, 5, 1))
    expected_order1.units = 10_000
    expected_order1.price = 135.6
    expected_order1.expiry = Time.utc(2015, 5, 2)
    expected_order1.lower_bound = 135.59
    expected_order1.upper_bound = 135.61
    expected_order1.stop_loss = 135.73
    expected_order1.take_profit = 0
    expected_order1.trailing_stop = 0

    expected_order2 = Jiji::Model::Trading::Order.new(
      :USDJPY, r2.internal_id, :buy, :stop, Time.utc(2015, 5, 1))
    expected_order2.units = 10_000
    expected_order2.price = 112.404
    expected_order2.expiry = Time.utc(2015, 5, 2)
    expected_order2.lower_bound = 0
    expected_order2.upper_bound = 0
    expected_order2.stop_loss = 0
    expected_order2.take_profit = 112.6
    expected_order2.trailing_stop = 0

    expected_order3 = Jiji::Model::Trading::Order.new(
      :EURUSD, r3.internal_id, :buy, :marketIfTouched, Time.utc(2015, 5, 1))
    expected_order3.units = 10_000
    expected_order3.price = 1.4325
    expected_order3.expiry = Time.utc(2015, 5, 2)
    expected_order3.lower_bound = 0
    expected_order3.upper_bound = 0
    expected_order3.stop_loss = 0
    expected_order3.take_profit = 0
    expected_order3.trailing_stop = 5

    expected_order4 = Jiji::Model::Trading::Order.new(
      :EURJPY, r4.internal_id, :sell, :limit, Time.utc(2015, 5, 1))
    expected_order4.units = 1000
    expected_order4.price = 136.6
    expected_order4.expiry = Time.utc(2015, 5, 1, 0, 0, 45)
    expected_order4.lower_bound = 0
    expected_order4.upper_bound = 0
    expected_order4.stop_loss = 140
    expected_order4.take_profit = 134
    expected_order4.trailing_stop = 10

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    expect(sort_by_internal_id(broker.orders)).to eq([
      expected_order1, expected_order2, expected_order3, expected_order4
    ])
    positions = broker.positions
    expect(sort_by_internal_id(positions)).to eq([])
    positions = position_repository.retrieve_positions(backtest_id)
    expect(sort_by_internal_id(positions)).to eq([])

    broker.refresh_positions
    broker.refresh

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    expect(sort_by_internal_id(broker.orders)).to eq([
      expected_order1, expected_order2, expected_order3, expected_order4
    ])
    positions = broker.positions
    expect(sort_by_internal_id(positions)).to eq([])
    positions = position_repository.retrieve_positions(backtest_id)
    expect(sort_by_internal_id(positions)).to eq([])

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    broker.refresh_positions
    broker.refresh

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    expect(sort_by_internal_id(broker.orders)).to eq([
      expected_order3, expected_order4
    ])

    expected_position1 = Jiji::Model::Trading::Position.new do |p|
      p.backtest      = backtest
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
      p.agent_id      = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        stop_loss: 135.73
      })
      p.current_counter_rate = 1
    end
    expected_position2 = Jiji::Model::Trading::Position.new do |p|
      p.backtest      = backtest
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
      p.agent_id      = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        take_profit: 112.6
      })
      p.current_counter_rate = 1
    end

    broker.refresh_positions

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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq(-340)
    expect(broker.account.margin_used.to_f).to eq(99_212.0)

    2.times do |_i|
      broker.refresh_positions
      broker.refresh

      expect(broker.account.balance).to eq 100_000
      expect(broker.account.profit_or_loss).to eq(-340)
      expect(broker.account.margin_used.to_f).not_to be nil

      tick = broker.tick

      expected_position1.current_price = tick[:EURJPY].ask
      expected_position1.updated_at    = tick.timestamp
      expected_position1.update_profit_or_loss
      expected_position2.current_price = tick[:USDJPY].bid
      expected_position2.updated_at    = tick.timestamp
      expected_position2.update_profit_or_loss

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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq(-340)
    expect(broker.account.margin_used.to_f).to eq(99_292.0)

    tick = broker.tick

    expected_position1.current_price = tick[:EURJPY].ask
    expected_position1.updated_at    = tick.timestamp
    expected_position1.exit_price    = tick[:EURJPY].ask
    expected_position1.exited_at     = tick.timestamp
    expected_position1.status        = :closed
    expected_position1.update_profit_or_loss

    expected_position2.current_price = tick[:USDJPY].bid
    expected_position2.updated_at    = tick.timestamp
    expected_position2.update_profit_or_loss

    expect(broker.orders).to eq([])

    expected_position3 = Jiji::Model::Trading::Position.new do |p|
      p.backtest      = backtest
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
      p.agent_id      = nil
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        trailing_stop:   5,
        trailing_amount: 1.5229
      })
      p.current_counter_rate = 112.51
    end

    broker.refresh_positions
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

    expect(broker.account.balance).to eq 98_700
    expect(broker.account.profit_or_loss).to eq(103_231.59)
    expect(broker.account.margin_used.to_f).to eq(45_609.36)

    positions = broker.positions
    position = find_by_internal_id(positions, r2.internal_id)
    position.close

    expect(broker.account.balance).to eq 99_660
    expect(broker.account.profit_or_loss).to eq(102_271.59)
    expect(broker.account.margin_used.to_f).to eq(609.36)

    expected_position2.exit_price    = tick[:USDJPY].bid
    expected_position2.exited_at     = tick.timestamp
    expected_position2.status        = :closed
    expected_position2.update_profit_or_loss

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

    expect(broker.account.balance).to eq 99_660
    expect(broker.account.profit_or_loss).to eq(103_397.609)
    expect(broker.account.margin_used.to_f).to eq(609.76)

    tick = broker.tick

    expected_position3.current_price = tick[:EURUSD].bid
    expected_position3.current_counter_rate = tick[:USDJPY].mid
    expected_position3.updated_at = tick.timestamp
    expected_position3.closing_policy.trailing_amount = 1.5239
    expected_position3.update_profit_or_loss

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

    expect(broker.account.balance).to eq 99_660
    expect(broker.account.profit_or_loss).to eq(103_397.609)
    expect(broker.account.margin_used.to_f).to eq(609.76)
  end

  it '建玉を変更できる' do
    positions = position_repository.retrieve_positions(backtest_id)
    expect(positions.length).to be 0

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    broker.tick

    result = broker.buy(:EURJPY, 10_000, :market, {
      stop_loss: 130
    }, agent_setting.id)
    expected_position = Jiji::Model::Trading::Position.new do |p|
      p.backtest      = backtest
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
      p.agent_id      = agent_setting.id
      p.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
        stop_loss: 130
      })
      p.current_counter_rate = 1
    end

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq(-300)
    expect(broker.account.margin_used).to eq 54_120.0

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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq(-300)
    expect(broker.account.margin_used).to eq 54_120.0

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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

    result = broker.sell(:EURJPY, 10_000, :limit, {
      price:       135.6,
      expiry:      Time.utc(2015, 5, 2),
      lower_bound: 135.59,
      upper_bound: 135.61,
      stop_loss:   135.73
    }).order_opened

    expected_order = Jiji::Model::Trading::Order.new(
      :EURJPY, result.internal_id, :sell, :limit, Time.utc(2015, 5, 1))
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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0
  end

  it '注文のキャンセルができる' do
    broker.tick

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0

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

    expect(broker.account.balance).to eq 100_000
    expect(broker.account.profit_or_loss).to eq 0
    expect(broker.account.margin_used).to eq 0
  end

  it '破棄操作ができる' do
    broker.destroy
  end

  describe '#retrieve_economic_calendar_informations' do
    it 'can retirieve economic calendar informations.' do
      check_event_information(
        broker.retrieve_economic_calendar_informations(2_592_000, :EURUSD))
      check_event_information(
        broker.retrieve_economic_calendar_informations(604_800))
    end

    def check_event_information(events)
      events.each do |event|
        expect(event.title).not_to be nil
        expect(event.currency).not_to be nil
        expect(event.region).not_to be nil
        expect(event.unit).not_to be nil
        expect(event.timestamp).not_to be nil
      end
    end
  end

  describe '#retrieve_rates' do
    it 'can retirieve historical rates.' do
      check_rates(broker.retrieve_rates(:EURJPY, :one_hour,
        Time.utc(2015, 5, 21, 12, 0o0, 0o0), Time.utc(2015, 5, 30, 12, 0, 0)),
        Time.utc(2015, 5, 21, 12, 0o0, 0o0), 60 * 60)
      check_rates(broker.retrieve_rates(:USDJPY, :one_minute,
        Time.utc(2015, 5, 21, 12, 0o0, 0o0), Time.utc(2015, 5, 22, 12, 0, 0)),
        Time.utc(2015, 5, 21, 12, 0o0, 0o0), 60)
    end

    def check_rates(rates, time, interval)
      rates.each do |rate|
        expect(rate.timestamp).to eq time
        check_tick_value(rate.open)
        check_tick_value(rate.close)
        check_tick_value(rate.high)
        check_tick_value(rate.low)
        expect(rate.volume).to be >= 0
        time = Time.at(time.to_i + interval).utc
      end
    end

    def check_tick_value(value)
      expect(value.bid).to be > 0
      expect(value.ask).to be > 0
    end
  end

  def sort_by_internal_id(orders_or_positions)
    orders_or_positions.sort_by { |o| o.internal_id }
  end

  def find_by_internal_id(orders_or_positions, internal_id)
    orders_or_positions.find { |o| o.internal_id == internal_id }
  end
end
