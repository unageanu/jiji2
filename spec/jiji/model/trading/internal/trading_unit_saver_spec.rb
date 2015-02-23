# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::TradingUnitSaver do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @saver = Jiji::Model::Trading::Internal::TradingUnitSaver.new
    @trading_unit = Jiji::Model::Trading::Internal::TradingUnit
  end

  after(:example) do
    @data_builder.clean
  end

  it '1回目の保存時に必ず保存される' do
    expect(@trading_unit.count).to eq 0

    @saver.save([
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:USDJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURUSD, 10_000)
    ], Time.at(1000))

    expect(@trading_unit.count).to eq 3

    items = @trading_unit.order_by(:pair_id.asc).all
    expect(items.length).to eq 3
    expect(items[0].trading_unit).to eq 10_000
    expect(items[0].timestamp).to eq Time.at(1000)
    expect(items[1].trading_unit).to eq 10_000
    expect(items[1].timestamp).to eq Time.at(1000)
    expect(items[2].trading_unit).to eq 10_000
    expect(items[2].timestamp).to eq Time.at(1000)
  end

  it '変更がなければ、保存は行われない' do
    @saver.save([
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:USDJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURUSD, 10_000)
    ], Time.at(1000))

    expect(@trading_unit.count).to eq 3

    @saver.save([
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:USDJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURUSD, 10_000)
    ], Time.at(2000))

    expect(@trading_unit.count).to eq 3

    @saver.save([
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:USDJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURUSD, 10_000)
    ], Time.at(3000))

    expect(@trading_unit.count).to eq 3
  end

  it '変更があれば、保存が行われる' do
    @saver.save([
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:USDJPY, 10_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURUSD, 10_000)
    ], Time.at(1000))

    expect(@trading_unit.count).to eq 3

    @saver.save([
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURJPY, 11_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:USDJPY, 11_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURUSD, 11_000)
    ], Time.at(2000))

    expect(@trading_unit.count).to eq 6

    @saver.save([
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:EURJPY, 11_000),
      JIJI::Plugin::SecuritiesPlugin::Pair.new(:USDJPY, 20_000)
    ], Time.at(3000))

    expect(@trading_unit.count).to eq 7
  end
end
