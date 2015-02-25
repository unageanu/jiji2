# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::TradingUnit do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    0.upto(10) do |i|
      (0..2).each do |pair_id|
        s = @data_builder.new_trading_unit(i, pair_id, Time.at(60 * i))
        s.save
      end
    end
  end

  after(:example) do
    @data_builder.clean
  end

  context '開始、終了期間と一致するtrading_unitが登録されいる場合' do
    it '期間内のtrading_unitの取得、参照ができる' do
      trading_units = Jiji::Model::Trading::Internal::TradingUnits
                      .create(Time.at(0), Time.at(60 * 5))

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(0))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(0)

      trading_unit = trading_units.get_trading_unit_at(1, Time.at(0))
      expect(trading_unit.pair_id).to eq(1)
      expect(trading_unit.trading_unit).to eq(0)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(10))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(0)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(60))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(10_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(61))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(10_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(60 * 5 - 1))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(40_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(60 * 5))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(50_000)

      expect do
        trading_units.get_trading_unit_at(0, Time.at(60 * 5 + 1))
      end.to raise_error(ArgumentError)

      expect do
        trading_units.get_trading_unit_at(0, Time.at(-1))
      end.to raise_error(ArgumentError)

      expect do
        trading_units.get_trading_unit_at(3, Time.at(10))
      end.to raise_error(Errors::NotFoundException)
    end
  end

  context '開始、終了期間と一致するtrading_unitが登録されいない場合' do
    it '期間内のtrading_unitの取得、参照ができる' do
      trading_units = Jiji::Model::Trading::Internal::TradingUnits
                      .create(Time.at(70), Time.at(60 * 5 + 10))

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(70))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(10_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(75))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(10_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(120))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(20_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(121))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(20_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(60 * 5 - 1))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(40_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(60 * 5))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(50_000)

      trading_unit = trading_units.get_trading_unit_at(0, Time.at(60 * 5 + 10))
      expect(trading_unit.pair_id).to eq(0)
      expect(trading_unit.trading_unit).to eq(50_000)

      expect do
        trading_units.get_trading_unit_at(0, Time.at(69))
      end.to raise_error(ArgumentError)

      expect do
        trading_units.get_trading_unit_at(0, Time.at(60 * 5 + 11))
      end.to raise_error(ArgumentError)
    end
  end

  it 'delete で trading_unit を削除できる' do
    expect(Jiji::Model::Trading::Internal::TradingUnit.count).to eq(33)

    Jiji::Model::Trading::Internal::TradingUnit
      .delete(Time.at(-50), Time.at(200))
    expect(Jiji::Model::Trading::Internal::TradingUnit.count).to eq(21)

    Jiji::Model::Trading::Internal::TradingUnit
      .delete(Time.at(240), Time.at(300))
    expect(Jiji::Model::Trading::Internal::TradingUnit.count).to eq(18)
  end
end
