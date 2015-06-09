
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

  it '売買ができる' do
    broker.tick

    result1 = broker.buy(:EURJPY, 1)
    expect(result1.order_opened).to be nil
    expect(result1.trade_opened.pair_name).to be :EURJPY
    expect(result1.trade_opened.sell_or_buy).to be :buy
    expect(result1.trade_opened.units).to be 1
    expect(result1.trade_opened.price).to be > 0
    expect(result1.trade_opened.last_modified).not_to be nil
    expect(result1.trade_reduced).to be nil
    expect(result1.trades_closed).to eq []

    result2 = broker.sell(:USDJPY, 2)
    expect(result2.order_opened).to be nil
    expect(result2.trade_opened.pair_name).to be :USDJPY
    expect(result2.trade_opened.sell_or_buy).to be :sell
    expect(result2.trade_opened.units).to be 2
    expect(result2.trade_opened.price).to be > 0
    expect(result2.trade_opened.last_modified).not_to be nil
    expect(result2.trade_reduced).to be nil
    expect(result2.trades_closed).to eq []

    expect(broker.positions.length).to be 2
    position = broker.positions[result1.trade_opened.internal_id]
    expect(position.pair_name).to be :EURJPY
    expect(position.sell_or_buy).to be :buy
    expect(position.units).to be 1
    expect(position.status).to be :live
    expect(position.entry_price).to be > 0
    expect(position.entered_at).not_to be nil
    expect(position.current_price).to be > 0
    expect(position.updated_at).not_to be nil
    expect(position.exit_price).to be nil
    expect(position.exited_at).to be nil

    position = broker.positions[result2.trade_opened.internal_id]
    expect(position.pair_name).to be :USDJPY
    expect(position.sell_or_buy).to be :sell
    expect(position.units).to be 2
    expect(position.status).to be :live
    expect(position.entry_price).to be > 0
    expect(position.entered_at).not_to be nil
    expect(position.current_price).to be > 0
    expect(position.updated_at).not_to be nil
    expect(position.exit_price).to be nil
    expect(position.exited_at).to be nil

    broker.refresh
    broker.tick

    position1 = broker.positions[result1.trade_opened.internal_id]
    position2 = broker.positions[result2.trade_opened.internal_id]

    broker.close_position(position1)
    expect(position1.pair_name).to be :EURJPY
    expect(position1.sell_or_buy).to be :buy
    expect(position1.units).to be 1
    expect(position1.status).to be :closed
    expect(position1.entry_price).to be > 0
    expect(position1.entered_at).not_to be nil
    expect(position1.current_price).to be > 0
    expect(position1.updated_at).not_to be nil
    expect(position1.exit_price).to be > 0
    expect(position1.exited_at).not_to be nil

    position2.close
    expect(position2.pair_name).to be :USDJPY
    expect(position2.sell_or_buy).to be :sell
    expect(position2.units).to be 2
    expect(position2.status).to be :closed
    expect(position2.entry_price).to be > 0
    expect(position2.entered_at).not_to be nil
    expect(position2.current_price).to be > 0
    expect(position2.updated_at).not_to be nil
    expect(position2.exit_price).to be > 0
    expect(position2.exited_at).not_to be nil

    expect(broker.positions.length).to be 0
  end

  it '売買していても既定のレートを取得できる' do
    broker.tick

    result = broker.buy(:EURJPY, 10_000)
    buy_position = broker.positions[result.trade_opened.internal_id]
    expect(buy_position.profit_or_loss).to eq(-300)
    expect(buy_position.entry_price).to eq 135.33
    expect(buy_position.entered_at).to eq Time.utc(2015, 5, 1)
    expect(buy_position.current_price).to eq 135.30
    expect(buy_position.updated_at).to eq Time.utc(2015, 5, 1)
    expect(buy_position.exit_price).to be nil
    expect(buy_position.exited_at).to be nil

    expect(broker.next?).to eq true
    expect(broker.tick[:EURJPY].bid).to eq 135.30

    broker.refresh

    expect(buy_position.profit_or_loss).to eq 2300
    expect(buy_position.entry_price).to eq 135.33
    expect(buy_position.entered_at).to eq Time.utc(2015, 5, 1)
    expect(buy_position.current_price).to eq 135.56
    expect(buy_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(buy_position.exit_price).to be nil
    expect(buy_position.exited_at).to be nil

    expect(broker.next?).to eq true
    expect(broker.tick[:EURJPY].bid).to eq 135.56

    result = broker.sell(:EURUSD, 10_000)
    sell_position = broker.positions[result.trade_opened.internal_id]
    expect(sell_position.profit_or_loss).to eq(-2)
    expect(sell_position.entry_price).to eq 1.3834
    expect(sell_position.entered_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(sell_position.current_price).to eq 1.3836
    expect(sell_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(sell_position.exit_price).to be nil
    expect(sell_position.exited_at).to be nil

    broker.close_position(buy_position)
    expect(buy_position.profit_or_loss).to eq 2300
    expect(buy_position.entry_price).to eq 135.33
    expect(buy_position.entered_at).to eq(Time.utc(2015, 5, 1))
    expect(buy_position.current_price).to eq 135.56
    expect(buy_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(buy_position.exit_price).to eq 135.56
    expect(buy_position.exited_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))

    broker.refresh

    expect(buy_position.profit_or_loss).to eq 2300
    expect(buy_position.entry_price).to eq 135.33
    expect(buy_position.entered_at).to eq Time.utc(2015, 5, 1)
    expect(buy_position.current_price).to eq 135.56
    expect(buy_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(buy_position.exit_price).to eq 135.56
    expect(buy_position.exited_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))

    expect(sell_position.profit_or_loss).to eq(-402)
    expect(sell_position.entry_price).to eq 1.3834
    expect(sell_position.entered_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(sell_position.current_price).to eq 1.4236
    expect(sell_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 0, 30))
    expect(sell_position.exit_price).to be nil
    expect(sell_position.exited_at).to be nil

    broker.refresh

    expect(buy_position.profit_or_loss).to eq 2300
    expect(sell_position.profit_or_loss).to eq(-432)
    expect(sell_position.entry_price).to eq 1.3834
    expect(sell_position.entered_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(sell_position.current_price).to eq 1.4266
    expect(sell_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 0, 45))
    expect(sell_position.exit_price).to be nil
    expect(sell_position.exited_at).to be nil

    broker.refresh

    expect(buy_position.profit_or_loss).to eq 2300
    expect(sell_position.profit_or_loss).to eq(-412)
    expect(sell_position.entry_price).to eq 1.3834
    expect(sell_position.entered_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(sell_position.current_price).to eq 1.4246
    expect(sell_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 1, 0))
    expect(sell_position.exit_price).to be nil
    expect(sell_position.exited_at).to be nil

    sell_position.close
    expect(sell_position.profit_or_loss).to eq(-412)
    expect(sell_position.entry_price).to eq 1.3834
    expect(sell_position.entered_at).to eq(Time.utc(2015, 5, 1, 0, 0, 15))
    expect(sell_position.current_price).to eq 1.4246
    expect(sell_position.updated_at).to eq(Time.utc(2015, 5, 1, 0, 1, 0))
    expect(sell_position.exit_price).to eq 1.4246
    expect(sell_position.exited_at).to eq(Time.utc(2015, 5, 1, 0, 1, 0))
  end

  it '破棄操作ができる' do
    broker.destroy
  end
end
