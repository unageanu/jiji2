# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Tick do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
  end

  after(:example) do
    @data_builder.clean
  end

  describe '+' do
    it '+ で値を合成できる' do
      a = Jiji::Model::Trading::Tick.new({
        EURUSD: @data_builder.new_tick_value(1),
        USDJPY: @data_builder.new_tick_value(2)
      }, Time.utc(2015,5,1,0,0,0))
      b = Jiji::Model::Trading::Tick.new({
        EURJPY: @data_builder.new_tick_value(3),
        USDJPY: @data_builder.new_tick_value(4)
      }, Time.utc(2015,5,1,0,0,0))

      merged = a + b
      expect(merged.timestamp).to eq Time.utc(2015,5,1,0,0,0)
      expect(merged.length).to be 3
      expect(merged[:EURUSD]).to eq @data_builder.new_tick_value(1)
      expect(merged[:EURJPY]).to eq @data_builder.new_tick_value(3)
      expect(merged[:USDJPY]).to eq @data_builder.new_tick_value(2)
    end

    it '時間が一致しない場合エラー' do
      a = Jiji::Model::Trading::Tick.new({
        EURUSD: @data_builder.new_tick_value(1),
        USDJPY: @data_builder.new_tick_value(2)
      }, Time.utc(2015,5,1,0,0,0))
      b = Jiji::Model::Trading::Tick.new({
        EURJPY: @data_builder.new_tick_value(3),
        USDJPY: @data_builder.new_tick_value(4)
      }, Time.utc(2015,5,1,0,0,1))

      expect do
        a + b
      end.to raise_error(ArgumentError)
    end
  end

  describe 'merge' do
    it 'tickの配列を合成できる' do

      eur_usd = [
        Jiji::Model::Trading::Tick.new({
          EURUSD: @data_builder.new_tick_value(1)
        }, Time.utc(2015,5,1,0,0,0)),
        Jiji::Model::Trading::Tick.new({
          EURUSD: @data_builder.new_tick_value(2)
        }, Time.utc(2015,5,1,1,0,0)),
        Jiji::Model::Trading::Tick.new({
          EURUSD: @data_builder.new_tick_value(3)
        }, Time.utc(2015,5,1,2,0,0)),
      ];
      eur_jpy = [
        Jiji::Model::Trading::Tick.new({
          EURJPY: @data_builder.new_tick_value(11)
        }, Time.utc(2015,5,1,0,0,0)),
        Jiji::Model::Trading::Tick.new({
          EURJPY: @data_builder.new_tick_value(12)
        }, Time.utc(2015,5,1,1,0,0)),
        Jiji::Model::Trading::Tick.new({
          EURJPY: @data_builder.new_tick_value(13)
        }, Time.utc(2015,5,1,3,0,0)),
      ];

      merged = Jiji::Model::Trading::Tick.merge(eur_usd, eur_jpy)
      expect(merged.length).to be 4
      expect(merged[0]).to eq Jiji::Model::Trading::Tick.new({
        EURUSD: @data_builder.new_tick_value(1),
        EURJPY: @data_builder.new_tick_value(11)
      }, Time.utc(2015,5,1,0,0,0))
      expect(merged[1]).to eq Jiji::Model::Trading::Tick.new({
        EURUSD: @data_builder.new_tick_value(2),
        EURJPY: @data_builder.new_tick_value(12)
      }, Time.utc(2015,5,1,1,0,0))
      expect(merged[2]).to eq Jiji::Model::Trading::Tick.new({
        EURUSD: @data_builder.new_tick_value(3)
      }, Time.utc(2015,5,1,2,0,0))
      expect(merged[3]).to eq Jiji::Model::Trading::Tick.new({
        EURJPY: @data_builder.new_tick_value(13)
      }, Time.utc(2015,5,1,3,0,0))
    end

  end
end
