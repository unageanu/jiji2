# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Position do
  include_context 'use agent_setting'
  let(:backtest) do
    backtests[0]
  end

  it 'バックテスト向け設定でPositionを作成できる' do
    position_builder =
      Jiji::Model::Trading::Internal::PositionBuilder.new(backtest)
    position = position_builder.build_from_tick(
      nil, :EURJPY, 10_000, :buy, data_builder.new_tick(1), 'JPY', {
        take_profit:     102,
        stop_loss:       100,
        trailing_stop:   5,
        trailing_amount: 10
    })
    position.agent = agent_setting
    position.save

    expect(position.backtest).to eq(backtest)
    expect(position.internal_id).to eq(nil)
    expect(position.pair_name).to eq(:EURJPY)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.00)
    expect(position.current_counter_rate).to eq(1)
    expect(position.profit_or_loss).to eq(-30)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
    expect(position.agent).to eq(agent_setting)
    expect(position.closing_policy.take_profit).to eq(102)
    expect(position.closing_policy.stop_loss).to eq(100)
    expect(position.closing_policy.trailing_stop).to eq(5)
    expect(position.closing_policy.trailing_amount).to eq(10)

    expect(Jiji::Model::Trading::Position.count).to eq(1)

    position = position_builder.build_from_tick(
      nil, :EURUSD, 20_000, :sell, data_builder.new_tick(1), 'JPY')
    position.save

    expect(position.backtest).to eq(backtest)
    expect(position.internal_id).to eq(nil)
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(20_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(101.00)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.003)
    expect(position.current_counter_rate).to eq(101.0015)
    expect(position.profit_or_loss).to eq(-6060.09)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
    expect(position.agent).to eq(nil)
    expect(position.closing_policy.take_profit).to eq(0)
    expect(position.closing_policy.stop_loss).to eq(0)
    expect(position.closing_policy.trailing_stop).to eq(0)
    expect(position.closing_policy.trailing_amount).to eq(0)

    expect(Jiji::Model::Trading::Position.count).to eq(2)
  end

  it 'RMT向け設定でPositionを作成できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 1_000_000, :sell, data_builder.new_tick(2), 'JPY', {
        take_profit:     102,
        stop_loss:       100,
        trailing_stop:   5,
        trailing_amount: 10
    })
    position.agent = agent_setting
    position.save

    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(1_000_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.current_counter_rate).to eq(102.0015)
    expect(position.profit_or_loss).to eq(-306_004.5)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
    expect(position.agent).to eq(agent_setting)
    expect(position.closing_policy.take_profit).to eq(102)
    expect(position.closing_policy.stop_loss).to eq(100)
    expect(position.closing_policy.trailing_stop).to eq(5)
    expect(position.closing_policy.trailing_amount).to eq(10)

    expect(Jiji::Model::Trading::Position.count).to eq(1)
  end

  it 'update で現在価値を更新できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      nil, :EURUSD, 10_000, :buy, data_builder.new_tick(1), 'JPY')

    expect(position.profit_or_loss).to eq(BigDecimal(-30, 10) * 101.0015)
    expect(position.max_drow_down).to eq(BigDecimal(-30, 10) * 101.0015)
    expect(position.current_counter_rate).to eq(101.0015)

    position.update_price(data_builder.new_tick(2, Time.at(100)), 'JPY')
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(102.00)
    expect(position.current_counter_rate).to eq(102.0015)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(BigDecimal(9970, 10) * 102.0015)
    expect(position.max_drow_down).to eq(BigDecimal(-30, 10) * 101.0015)

    position.update_price(data_builder.new_tick(3, Time.at(200)), 'JPY')
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(103.00)
    expect(position.current_counter_rate).to eq(103.0015)
    expect(position.updated_at).to eq(Time.at(200))
    expect(position.profit_or_loss).to eq(BigDecimal(19_970, 10) * 103.0015)
    expect(position.max_drow_down).to eq(BigDecimal(-30, 10) * 101.0015)

    position.update_price(data_builder.new_tick(0, Time.at(300)), 'JPY')
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(100.00)
    expect(position.current_counter_rate).to eq(100.0015)
    expect(position.updated_at).to eq(Time.at(300))
    expect(position.profit_or_loss).to eq(
      BigDecimal(-10_030, 10) * 100.0015)
    expect(position.max_drow_down).to eq(
      BigDecimal(-10_030, 10) * 100.0015)

    position = position_builder.build_from_tick(
      1, :EURUSD, 100_000, :sell, data_builder.new_tick(1), 'JPY')

    expect(position.profit_or_loss).to eq(BigDecimal(-300, 10) * 101.0015)
    expect(position.max_drow_down).to eq(BigDecimal(-300, 10) * 101.0015)

    position.update_price(data_builder.new_tick(2, Time.at(100)), 'JPY')
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(102.003)
    expect(position.current_counter_rate).to eq(102.0015)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(
      BigDecimal(-100_300, 10) * 102.0015)
    expect(position.max_drow_down).to eq(
      BigDecimal(-100_300, 10) * 102.0015)

    position.update_price(data_builder.new_tick(3, Time.at(200)), 'JPY')
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(103.003)
    expect(position.current_counter_rate).to eq(103.0015)
    expect(position.updated_at).to eq(Time.at(200))
    expect(position.profit_or_loss).to eq(
      BigDecimal(-200_300, 10) * 103.0015)
    expect(position.max_drow_down).to eq(
      BigDecimal(-200_300, 10) * 103.0015)

    position.update_price(data_builder.new_tick(0, Time.at(100)), 'JPY')
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(100.003)
    expect(position.current_counter_rate).to eq(100.0015)
    expect(position.updated_at).to eq(Time.at(100))
    expect(BigDecimal(position.profit_or_loss, 10)).to eq(
      BigDecimal(99_700, 10) * 100.0015)
    expect(position.max_drow_down).to eq(
      BigDecimal(-200_300, 10) * 103.0015)
  end

  it 'update_state_for_reduce で取引数を削減できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1), 'JPY')

    position.update_state_for_reduce(1000, Time.at(100))
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(9_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.0)
    expect(position.current_counter_rate).to eq(101.0015)
    expect(position.profit_or_loss).to eq(-2727.0405)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)
  end

  it 'update_state_to_lost でロスト状態にできる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1), 'JPY')

    position.update_state_to_lost(103, Time.at(300))
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(103.0)
    expect(position.current_counter_rate).to eq(101.0015)
    expect(position.profit_or_loss).to eq(2_016_999.955)
    expect(position.updated_at).to eq(Time.at(300))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:lost)
  end

  it 'update_state_to_closed で約定済み状態にできる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1), 'JPY')

    position.update_state_to_closed
    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.0)
    expect(position.current_counter_rate).to eq(101.0015)
    expect(position.profit_or_loss).to eq(-3030.045)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(101.0)
    expect(position.exited_at).to eq(Time.at(0))
    expect(position.status).to eq(:closed)

    position_builder =
      Jiji::Model::Trading::Internal::PositionBuilder.new(backtest)
    position = position_builder.build_from_tick(
      nil, :EURUSD, 10_000, :sell, data_builder.new_tick(1), 'JPY')

    position.update_price(data_builder.new_tick(2, Time.at(100)), 'JPY')

    position.update_state_to_closed(103, Time.at(300), -3000.043)
    expect(position.backtest).to eq(backtest)
    expect(position.internal_id).to eq(nil)
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(101.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(103)
    expect(position.current_counter_rate).to eq(102.0015)
    expect(position.profit_or_loss).to eq(-3000.043)
    expect(position.updated_at).to eq(Time.at(300))
    expect(position.exit_price).to eq(103)
    expect(position.exited_at).to eq(Time.at(300))
    expect(position.status).to eq(:closed)
  end

  it 'close後は、updateやreduceを行うことはできない' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    position = position_builder.build_from_tick(
      '1', :EURUSD, 10_000, :buy, data_builder.new_tick(1), 'JPY')

    position.update_state_to_closed
    position.update_price(data_builder.new_tick(2, Time.at(100)), 'JPY')
    position.update_state_for_reduce(1000, Time.at(100))

    expect(position.backtest_id).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.0)
    expect(position.current_counter_rate).to eq(101.0015)
    expect(position.profit_or_loss).to eq(-3030.045)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(101.0)
    expect(position.exited_at).to eq(Time.at(0))
    expect(position.status).to eq(:closed)
  end

  it 'saveで永続化できる' do
    position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
    original = position_builder.build_from_tick(
      '1', :EURUSD, 1_000_000, :sell, data_builder.new_tick(2), 'JPY', {
        take_profit:     102,
        stop_loss:       100,
        trailing_stop:   5,
        trailing_amount: 10
    })
    original.agent = agent_setting
    original.save

    position = Jiji::Model::Trading::Position.find(original.id)
    expect(position.backtest).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(1_000_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.current_counter_rate).to eq(102.0015)
    expect(position.profit_or_loss).to eq(-306_004.5)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to be nil
    expect(position.exited_at).to be nil
    expect(position.status).to eq(:live)
    expect(position.agent).to eq(agent_setting)
    expect(position.closing_policy).to eq(original.closing_policy)

    original.closing_policy.trailing_amount = 11
    original.save

    position = Jiji::Model::Trading::Position.find(original.id)
    expect(position.backtest).to eq(nil)
    expect(position.internal_id).to eq('1')
    expect(position.pair_name).to eq(:EURUSD)
    expect(position.units).to eq(1_000_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.current_counter_rate).to eq(102.0015)
    expect(position.profit_or_loss).to eq(-306_004.5)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to be nil
    expect(position.exited_at).to be nil
    expect(position.status).to eq(:live)
    expect(position.agent).to eq(agent_setting)
    expect(position.closing_policy).to eq(original.closing_policy)
  end

  describe '#to_h' do
    it 'agentとbacktestが設定されてる場合' do
      position_builder =
        Jiji::Model::Trading::Internal::PositionBuilder.new(backtest)
      position = position_builder.build_from_tick(
        '1', :EURUSD, 1_000_000, :sell, data_builder.new_tick(2), 'JPY', {
          take_profit:     102,
          stop_loss:       100,
          trailing_stop:   5,
          trailing_amount: 10
      })
      position.agent = agent_setting

      hash = position.to_h

      expect(hash[:backtest]).to eq({
        id: backtest.id, name: 'テスト1'
      })
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
      expect(hash[:agent]).to eq({
        id:      agent_setting.id,
        name:    'test1',
        icon_id: agent_setting.icon_id
      })
      expect(hash[:closing_policy][:take_profit]).to eq(102)
      expect(hash[:closing_policy][:stop_loss]).to eq(100)
      expect(hash[:closing_policy][:trailing_stop]).to eq(5)
      expect(hash[:closing_policy][:trailing_amount]).to eq(10)
    end
    it 'agentとbacktestが未設定の場合' do
      position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
      position = position_builder.build_from_tick(
        '1', :EURUSD, 1_000_000, :sell, data_builder.new_tick(2), 'JPY', {
          take_profit:     102,
          stop_loss:       100,
          trailing_stop:   5,
          trailing_amount: 10
      })

      hash = position.to_h

      expect(hash[:backtest]).to eq({})
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
      expect(hash[:agent]).to eq({})
      expect(hash[:closing_policy][:take_profit]).to eq(102)
      expect(hash[:closing_policy][:stop_loss]).to eq(100)
      expect(hash[:closing_policy][:trailing_stop]).to eq(5)
      expect(hash[:closing_policy][:trailing_amount]).to eq(10)
    end
  end
end
