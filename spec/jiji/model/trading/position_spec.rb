# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Position do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
  end

  after(:example) do
    @data_builder.clean
  end

  it 'バックテスト向け設定でPositionを作成できる' do
    position = Jiji::Model::Trading::Position.create(
      'test', nil, 1, 1, 10_000, :buy, @data_builder.new_tick(1))

    expect(position.back_test_id).to eq('test')
    expect(position.external_position_id).to eq(nil)
    expect(position.pair_id).to eq(1)
    expect(position.lot).to eq(1)
    expect(position.trading_unit).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.00)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)

    expect(Jiji::Model::Trading::Position.count).to eq(1)

    position = Jiji::Model::Trading::Position.create(
      'test', nil, 2, 2, 10_000, :sell, @data_builder.new_tick(1))

    expect(position.back_test_id).to eq('test')
    expect(position.external_position_id).to eq(nil)
    expect(position.pair_id).to eq(2)
    expect(position.lot).to eq(2)
    expect(position.trading_unit).to eq(10_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(101.00)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.003)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)

    expect(Jiji::Model::Trading::Position.count).to eq(2)
  end

  it 'RMT向け設定でPositionを作成できる' do
    position = Jiji::Model::Trading::Position.create(
      nil, '1', 2, 100, 10_000, :sell, @data_builder.new_tick(2))

    expect(position.back_test_id).to eq(nil)
    expect(position.external_position_id).to eq('1')
    expect(position.pair_id).to eq(2)
    expect(position.lot).to eq(100)
    expect(position.trading_unit).to eq(10_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)

    expect(Jiji::Model::Trading::Position.count).to eq(1)
  end

  it 'update で現在価値を更新できる' do
    position = Jiji::Model::Trading::Position.create(
      'test', nil, '1', 1, 10_000, :buy, @data_builder.new_tick(1))

    expect(position.profit_or_loss).to eq(-30)

    position.update(@data_builder.new_tick(2, Time.at(100)))
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(102.00)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(9970)

    position.update(@data_builder.new_tick(3, Time.at(200)))
    expect(position.entry_price).to eq(101.003)
    expect(position.current_price).to eq(103.00)
    expect(position.updated_at).to eq(Time.at(200))
    expect(position.profit_or_loss).to eq(19_970)

    position = Jiji::Model::Trading::Position.create(
      nil, 1, 1, 10, 10_000, :sell, @data_builder.new_tick(1))

    expect(position.profit_or_loss).to eq(-300)

    position.update(@data_builder.new_tick(2, Time.at(100)))
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(-100_300)

    position.update(@data_builder.new_tick(3, Time.at(200)))
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(103.003)
    expect(position.updated_at).to eq(Time.at(200))
    expect(position.profit_or_loss).to eq(-200_300)

    position.update(@data_builder.new_tick(0, Time.at(100)))
    expect(position.entry_price).to eq(101.00)
    expect(position.current_price).to eq(100.003)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.profit_or_loss).to eq(99_700)
  end

  it 'close で約定済み状態にできる' do
    position = Jiji::Model::Trading::Position.create(
      nil, '1', 2, 1, 10_000, :buy, @data_builder.new_tick(1))

    position.close
    expect(position.back_test_id).to eq(nil)
    expect(position.external_position_id).to eq('1')
    expect(position.pair_id).to eq(2)
    expect(position.lot).to eq(1)
    expect(position.trading_unit).to eq(10_000)
    expect(position.sell_or_buy).to eq(:buy)
    expect(position.entry_price).to eq(101.003)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(101.0)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(101.0)
    expect(position.exited_at).to eq(Time.at(0))
    expect(position.status).to eq(:closed)

    position = Jiji::Model::Trading::Position.create(
      'test', nil, 1, 1, 10_000, :sell, @data_builder.new_tick(1))

    position.update(@data_builder.new_tick(2, Time.at(100)))

    position.close
    expect(position.back_test_id).to eq('test')
    expect(position.external_position_id).to eq(nil)
    expect(position.pair_id).to eq(1)
    expect(position.lot).to eq(1)
    expect(position.trading_unit).to eq(10_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(101.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(100))
    expect(position.exit_price).to eq(102.003)
    expect(position.exited_at).to eq(Time.at(100))
    expect(position.status).to eq(:closed)
  end

  it 'to_hでハッシュに変換できる' do
    position = Jiji::Model::Trading::Position.create(
      nil, '1', 2, 100, 10_000, :sell, @data_builder.new_tick(2))

    expect(position.back_test_id).to eq(nil)
    expect(position.external_position_id).to eq('1')
    expect(position.pair_id).to eq(2)
    expect(position.lot).to eq(100)
    expect(position.trading_unit).to eq(10_000)
    expect(position.sell_or_buy).to eq(:sell)
    expect(position.entry_price).to eq(102.0)
    expect(position.entered_at).to eq(Time.at(0))
    expect(position.current_price).to eq(102.003)
    expect(position.updated_at).to eq(Time.at(0))
    expect(position.exit_price).to eq(nil)
    expect(position.exited_at).to eq(nil)
    expect(position.status).to eq(:live)

    expect(Jiji::Model::Trading::Position.count).to eq(1)
  end
end
