# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

RSpec.shared_examples '建玉関連の操作' do
  describe Jiji::Model::Securities::Internal::Oanda::Trading do
    let(:tick) { client.retrieve_current_tick }
    let(:now)  { Time.now.round }
    let(:data_builder) { Jiji::Test::DataBuilder.new }

    before(:example) do
      data_builder.cancel_all_orders_and_positions(client, wait)
    end

    after(:example) do
      data_builder.cancel_all_orders_and_positions(client, wait)
    end

    it '建玉の情報を取得できる' do
      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0

      ask = BigDecimal(tick[:USDJPY].ask, 4)

      client.order(:EURJPY, :sell, 1)

      sleep wait
      client.order(:USDJPY, :buy, 2, :market, {
        stop_loss:     (ask - 2).to_f,
        take_profit:   (ask + 2).to_f,
        trailing_stop: 5
      })

      sleep wait
      trades = client.retrieve_trades

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

      trade = client.retrieve_trade_by_id(trades[1].internal_id)
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

      trade = client.retrieve_trade_by_id(trades[0].internal_id)
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

      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0
    end

    it '建玉の内容を変更できる' do
      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0

      bid = BigDecimal(tick[:EURJPY].bid, 4)
      ask = BigDecimal(tick[:USDJPY].ask, 4)

      client.order(:EURJPY, :sell, 1)

      sleep wait
      client.order(:USDJPY, :buy, 2, :market, {
        stop_loss:     (ask - 2).to_f,
        take_profit:   (ask + 2).to_f,
        trailing_stop: 5
      })

      sleep wait
      trades = client.retrieve_trades
      expect(trades.length).to be 2

      sleep wait
      trade = client.modify_trade(trades[1].internal_id, {
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
      trade = client.modify_trade(trades[0].internal_id, {
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
      trades = client.retrieve_trades
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

      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0
    end

    it '建玉を決済できる' do
      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0

      ask = BigDecimal(tick[:USDJPY].ask, 4)

      client.order(:EURJPY, :sell, 1)

      sleep wait
      client.order(:USDJPY, :buy, 2, :market, {
        stop_loss:     (ask - 2).to_f,
        take_profit:   (ask + 2).to_f,
        trailing_stop: 5
      })

      sleep wait
      trades = client.retrieve_trades
      expect(trades.length).to be 2

      sleep wait
      result = client.close_trade(trades[1].internal_id)
      expect(result.internal_id).to eq trades[1].internal_id
      expect(result.units).to eq(-1)
      expect(result.price).to be > 0
      expect(result.profit_or_loss).not_to be nil
      expect(result.timestamp).not_to be nil

      sleep wait
      result = client.close_trade(trades[0].internal_id)
      expect(result.internal_id).to eq trades[0].internal_id
      expect(result.units).to eq(-1)
      expect(result.price).to be > 0
      expect(result.profit_or_loss).not_to be nil
      expect(result.timestamp).not_to be nil

      sleep wait
      trades = client.retrieve_trades
      expect(trades.length).to be 0

      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0
    end

    it 'クロス円でない建玉を決済できる' do
      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0

      ask = BigDecimal(tick[:EURDKK].ask, 4)

      client.order(:AUDCAD, :sell, 1)

      sleep wait
      client.order(:EURDKK, :buy, 2, :market, {
        stop_loss:     (ask - 0.02).to_f,
        take_profit:   (ask + 0.02).to_f,
        trailing_stop: 5
      })

      sleep wait
      trades = client.retrieve_trades
      expect(trades.length).to be 2

      sleep wait
      result = client.close_trade(trades[1].internal_id)
      expect(result.internal_id).to eq trades[1].internal_id
      expect(result.units).to eq(-1)
      expect(result.price).to be > 0
      expect(result.profit_or_loss).not_to be nil
      expect(result.timestamp).not_to be nil

      sleep wait
      result = client.close_trade(trades[0].internal_id)
      expect(result.internal_id).to eq trades[0].internal_id
      expect(result.units).to eq(-1)
      expect(result.price).to be > 0
      expect(result.profit_or_loss).not_to be nil
      expect(result.timestamp).not_to be nil

      sleep wait
      trades = client.retrieve_trades
      expect(trades.length).to be 0

      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0
    end
  end
end
