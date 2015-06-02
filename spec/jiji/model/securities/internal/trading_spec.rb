# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

describe Jiji::Model::Securities::Internal::Trading do
  let(:wait) { 1 }
  let(:tick) { @client.retrieve_current_tick }
  let(:now)  {  Time.now.round }

  before(:example) do
    @client = Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  after(:example) do
    @client.retrieve_orders.each do |o|
      sleep wait
      begin
        @client.cancel_order(o.internal_id)
      rescue
        p $ERROR_INFO
      end
    end
    sleep wait
    @client.retrieve_trades.each do |t|
      sleep wait
      begin
        @client.close_trade(t.internal_id)
      rescue
        p $ERROR_INFO
      end
    end
  end

  it '建玉の情報を取得できる' do
    ask = BigDecimal.new(tick[:USDJPY].ask, 4)

    @client.order(:EURJPY, :sell, 1)

    sleep wait
    @client.order(:USDJPY, :buy, 2, :market, {
      stop_loss:     (ask - 2).to_f,
      take_profit:   (ask + 2).to_f,
      trailing_stop: 5
    })

    sleep wait
    trades = @client.retrieve_trades
    expect(trades.length).to be 2
    trade = trades[1]
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :EURJPY
    expect(trade.units).to eq 1
    expect(trade.sell_or_buy).to eq :sell
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq(0)
    expect(trade.closing_policy.take_profit).to eq(0)
    expect(trade.closing_policy.trailing_stop).to eq(0)
    expect(trade.closing_policy.trailing_amount).to eq(0)

    trade = trades[0]
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :USDJPY
    expect(trade.units).to eq 2
    expect(trade.sell_or_buy).to eq :buy
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq((ask - 2).to_f)
    expect(trade.closing_policy.take_profit).to eq((ask + 2).to_f)
    expect(trade.closing_policy.trailing_stop).to eq(5)
    expect(trade.closing_policy.trailing_amount).not_to be nil

    trade = @client.retrieve_trade_by_id(trades[1].internal_id)
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :EURJPY
    expect(trade.units).to eq 1
    expect(trade.sell_or_buy).to eq :sell
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq(0)
    expect(trade.closing_policy.take_profit).to eq(0)
    expect(trade.closing_policy.trailing_stop).to eq(0)
    expect(trade.closing_policy.trailing_amount).to eq(0)

    trade = @client.retrieve_trade_by_id(trades[0].internal_id)
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :USDJPY
    expect(trade.units).to eq 2
    expect(trade.sell_or_buy).to eq :buy
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq((ask - 2).to_f)
    expect(trade.closing_policy.take_profit).to eq((ask + 2).to_f)
    expect(trade.closing_policy.trailing_stop).to eq(5)
    expect(trade.closing_policy.trailing_amount).not_to be nil
  end

  it '建玉の内容を変更できる' do
    bid = BigDecimal.new(tick[:EURJPY].bid, 4)
    ask = BigDecimal.new(tick[:USDJPY].ask, 4)

    @client.order(:EURJPY, :sell, 1)

    sleep wait
    @client.order(:USDJPY, :buy, 2, :market, {
      stop_loss:     (ask - 2).to_f,
      take_profit:   (ask + 2).to_f,
      trailing_stop: 5
    })

    sleep wait
    trades = @client.retrieve_trades
    expect(trades.length).to be 2

    sleep wait
    trade = @client.modify_trade(trades[1].internal_id, {
      stop_loss:     (bid + 3).to_f,
      take_profit:   (bid - 3).to_f,
      trailing_stop: 6
    })
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :EURJPY
    expect(trade.units).to eq 1
    expect(trade.sell_or_buy).to eq :sell
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq((bid + 3).to_f)
    expect(trade.closing_policy.take_profit).to eq((bid - 3).to_f)
    expect(trade.closing_policy.trailing_stop).to eq(6)
    expect(trade.closing_policy.trailing_amount).not_to be nil

    sleep wait
    trade = @client.modify_trade(trades[0].internal_id, {
      stop_loss:     (ask - 3).to_f,
      take_profit:   (ask + 3).to_f,
      trailing_stop: 7
    })
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :USDJPY
    expect(trade.units).to eq 2
    expect(trade.sell_or_buy).to eq :buy
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq((ask - 3).to_f)
    expect(trade.closing_policy.take_profit).to eq((ask + 3).to_f)
    expect(trade.closing_policy.trailing_stop).to eq(7)
    expect(trade.closing_policy.trailing_amount).not_to be nil

    sleep wait
    trades = @client.retrieve_trades
    expect(trades.length).to be 2
    trade = trades[1]
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :EURJPY
    expect(trade.units).to eq 1
    expect(trade.sell_or_buy).to eq :sell
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq((bid + 3).to_f)
    expect(trade.closing_policy.take_profit).to eq((bid - 3).to_f)
    expect(trade.closing_policy.trailing_stop).to eq(6)
    expect(trade.closing_policy.trailing_amount).not_to be nil

    trade = trades[0]
    expect(trade.internal_id).not_to be nil
    expect(trade.pair_name).to eq :USDJPY
    expect(trade.units).to eq 2
    expect(trade.sell_or_buy).to eq :buy
    expect(trade.status).to eq :live
    expect(trade.entry_price).not_to be nil
    expect(trade.entered_at).not_to be nil
    expect(trade.closing_policy.stop_loss).to eq((ask - 3).to_f)
    expect(trade.closing_policy.take_profit).to eq((ask + 3).to_f)
    expect(trade.closing_policy.trailing_stop).to eq(7)
    expect(trade.closing_policy.trailing_amount).not_to be nil
  end

  it '建玉をキャンセルできる' do
    ask = BigDecimal.new(tick[:USDJPY].ask, 4)

    @client.order(:EURJPY, :sell, 1)

    sleep wait
    @client.order(:USDJPY, :buy, 2, :market, {
      stop_loss:     (ask - 2).to_f,
      take_profit:   (ask + 2).to_f,
      trailing_stop: 5
    })

    sleep wait
    trades = @client.retrieve_trades
    expect(trades.length).to be 2

    sleep wait
    result = @client.close_trade(trades[1].internal_id)
    expect(result.internal_id).not_to be nil
    expect(result.units).to eq(-1)
    expect(result.price).to be > 0
    expect(result.timestamp).not_to be nil

    sleep wait
    result = @client.close_trade(trades[0].internal_id)
    expect(result.internal_id).not_to be nil
    expect(result.units).to eq(-1)
    expect(result.price).to be > 0
    expect(result.timestamp).not_to be nil

    sleep wait
    trades = @client.retrieve_trades
    expect(trades.length).to be 0
  end
end
