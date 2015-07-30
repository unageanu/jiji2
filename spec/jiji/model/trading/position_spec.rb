# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Position do
  include_context 'use data_builder'

  it 'バックテスト向け設定でPositionを作成できる' do
    position_builder =
      Jiji::Model::Trading::Internal::PositionBuilder.new('test')
    position = position_builder.build_from_tick(
      nil, :EURJPY, 10_000, :buy, data_builder.new_tick(1), {
        take_profit:     102,
        stop_loss:       100,
        trailing_stop:   5,
        trailing_amount: 10
    })
    position.agent_name = 'テストエージェント'
    position.agent_id   = 'id'
    position.save

    expect(position.backtest_id).to eq('test')
    expect(position.internal_id).to eq(nil)
    expect(position.pair_name).to eq(:EURJPY)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.00)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
    expect(position.agent_name).to eq('テストエージェント')
    expect(position.agent_id).to eq('id')
    expect(position.closing_policy.take_profit).to eq(102)
    expect(position.closing_policy.stop_loss).to eq(100)
    expect(position.closing_policy.trailing_stop).to eq(5)
    expect(position.closing_policy.trailing_amount).to eq(10)

    expect(Jiji::Model::Trading::Position.count).to eq(1)

    position = position_builder.build_from_tick(
      nil, :EURUSD, 20_000, :sell, data_builder.new_tick(1))
    position.save

    expect(position.backtest_id).to eq('test')
    expect(position.internal_id).to eq(nil)
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(20_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(101.00)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.003)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
    expect(position.agent_name).to eq(nil)
    expect(position.agent_id).to eq(nil)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(0)
    expect(position.closing_policy.trailing_amount).to eq(0)

    expect(Jiji::Model::Trading::Position.count).to eq(2)
  end

  it 'RMT向け設定でPositionを作成できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 1_000_000, :sell, data_builder.new_tick(2), {
        take_profit:     102,
        stop_loss:       100,
        trailing_stop:   5,
        trailing_amount: 10
    })
    position.agent_name = 'テストエージェント'
    position.agent_id   = 'id'
    position.save

    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(1_000_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
    expect(position.agent_name).to eq('テストエージェント')
    expect(position.agent_id).to eq('id')
    expect(position.closing_policy.take_profit).to eq(102)
    expect(position.closing_policy.stop_loss).to eq(100)
    expect(position.closing_policy.trailing_stop).to eq(5)
    expect(position.closing_policy.trailing_amount).to eq(10)

    expect(Jiji::Model::Trading::Position.count).to eq(1)
  end

  it 'update で現在価値を更新できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      nil, :EURUSD, 10_000, :buy, data_builder.new_tick(1))

    expect(position.profit_or_loss).to eq(-30)
    expect(position.max_drow_down).to eq(-30)

    position.update_price(data_builder.new_tick(2, Time.at(100)))
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(102.00)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(9970)
    expect(position.max_drow_down).to eq(-30)

    position.update_price(data_builder.new_tick(3, Time.at(200)))
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(103.00)
    expect(position.updated_at).to eq(Time.at(200))
    expect(position.profit_or_loss).to eq(19_970)
    expect(position.max_drow_down).to eq(-30)

    position.update_price(data_builder.new_tick(0, Time.at(300)))
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(100.00)
    expect(position.updated_at).to eq(Time.at(300))
    expect(position.profit_or_loss).to eq(-10_030)
    expect(position.max_drow_down).to eq(-10_030)

    position = position_builder.build_from_tick(
      1, :EURUSD, 100_000, :sell, data_builder.new_tick(1))

    expect(position.profit_or_loss).to eq(-300)
    expect(position.max_drow_down).to eq(-300)

    position.update_price(data_builder.new_tick(2, Time.at(100)))
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(-100_300)
    expect(position.max_drow_down).to eq(-100_300)

    position.update_price(data_builder.new_tick(3, Time.at(200)))
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(103.003)
    expect(position.updated_at).to eq(Time.at(200))
    expect(position.profit_or_loss).to eq(-200_300)
    expect(position.max_drow_down).to eq(-200_300)

    position.update_price(data_builder.new_tick(0, Time.at(100)))
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(100.003)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(99_700)
    expect(position.max_drow_down).to eq(-200_300)
  end

  it 'update_state_for_reduce で取引数を削減できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1))

    position.update_state_for_reduce(1000, Time.at(100))
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(9_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.0)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
  end

  it 'update_state_to_lost でロスト状態にできる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1))

    position.update_state_to_lost(103, Time.at(300))
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(103.0)
    expect(position.updated_at).to eq(Time.at(300))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:lost)
  end

  it 'update_state_to_closed で約定済み状態にできる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1))

    position.update_state_to_closed
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.0)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(101.0)
    expect(position.exited_at).to eq(Time.at(0))
    expect(position.status).to eq(:closed)

    position_builder =
      Jiji::Model::Trading::Internal::PositionBuilder.new('test')
    position = position_builder.build_from_tick(
      nil, :EURUSD, 10_000, :sell, data_builder.new_tick(1))

    position.update_price(data_builder.new_tick(2, Time.at(100)))

    position.update_state_to_closed(103, Time.at(300))
    expect(position.backtest_id).to eq('test')
    expect(position.internal_id).to eq(nil)
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(101.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(103)
    expect(position.updated_at).to eq(Time.at(300))
    expect(position.exit_price).to eq(103)
    expect(position.exited_at).to eq(Time.at(300))
    expect(position.status).to eq(:closed)
  end

  it 'close後は、updateやreduceを行うことはできない' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1))

    position.update_state_to_closed
    position.update_price(data_builder.new_tick(2, Time.at(100)))
    position.update_state_for_reduce(1000, Time.at(100))

    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.0)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(101.0)
    expect(position.exited_at).to eq(Time.at(0))
    expect(position.status).to eq(:closed)
  end

  it 'saveで永続化できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    original = position_builder.build_from_tick(
      '1', :EURUSD, 1_000_000, :sell, data_builder.new_tick(2), {
        take_profit:     102,
        stop_loss:       100,
        trailing_stop:   5,
        trailing_amount: 10
    })
    original.agent_name = 'テストエージェント'
    original.agent_id   = 'id'
    original.save

    position = Jiji::Model::Trading::Position.find(original.id)
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(1_000_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to be nil
    expect(position.exited_at).to be nil
    expect(position.status).to eq(:live)
    expect(position.agent_name).to eq('テストエージェント')
    expect(position.agent_id).to eq('id')
    expect(position.closing_policy).to eq(original.closing_policy)

    original.closing_policy.trailing_amount = 11
    original.save

    position = Jiji::Model::Trading::Position.find(original.id)
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(1_000_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to be nil
    expect(position.exited_at).to be nil
    expect(position.status).to eq(:live)
    expect(position.agent_name).to eq('テストエージェント')
    expect(position.agent_id).to eq('id')
    expect(position.closing_policy).to eq(original.closing_policy)
  end

  it 'to_hでハッシュに変換できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 1_000_000, :sell, data_builder.new_tick(2), {
        take_profit:     102,
        stop_loss:       100,
        trailing_stop:   5,
        trailing_amount: 10
    })
    position.agent_name = 'テストエージェント'
    position.agent_id   = 'id'

    hash = position.to_h

    expect(hash[:backtest_id]).to eq(nil)
    expect(hash[:internal_id]).to eq('1')
    expect(hash[:pair_name]).to eq(:EURUSD)
    expect(hash[:units]).to eq(1_000_000)
    expect(hash[:sell_or_buy]).to eq(:sell)
    expect(hash[:entry_price]).to eq(102.0)
    expect(hash[:entered_at]).to eq(Time.at(0))
    expect(hash[:current_price]).to eq(102.003)
    expect(hash[:updated_at]).to eq(Time.at(0))
    expect(hash[:exit_price]).to eq(nil)
    expect(hash[:exited_at]).to eq(nil)
    expect(hash[:status]).to eq(:live)
    expect(hash[:agent_name]).to eq('テストエージェント')
    expect(hash[:agent_id]).to eq('id')
    expect(hash[:closing_policy][:take_profit]).to eq(102)
    expect(hash[:closing_policy][:stop_loss]).to eq(100)
    expect(hash[:closing_policy][:trailing_stop]).to eq(5)
    expect(hash[:closing_policy][:trailing_amount]).to eq(10)
  end
end
