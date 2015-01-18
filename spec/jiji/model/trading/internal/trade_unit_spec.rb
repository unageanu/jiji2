# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::TradeUnit do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    
    0.upto(10) {|i|
      (0..2).each {|pair_id|
        s = @data_builder.new_trade_unit(i, pair_id, Time.at(60*i))
        s.save
      }
    }
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  context "開始、終了期間と一致するtrade_unitが登録されいる場合" do
    it "期間内のtrade_unitの取得、参照ができる" do
      trade_units = Jiji::Model::Trading::Internal::TradeUnits.create( Time.at(0), Time.at(60*5) )
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(0))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(0)
      
      trade_unit = trade_units.get_trade_unit_at(1, Time.at(0))
      expect(trade_unit.pair_id).to eq(1)
      expect(trade_unit.trade_unit).to eq(0)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(10))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(0)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(60))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(10000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(61))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(10000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(60*5-1))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(40000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(60*5))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(50000)
      
      expect {
        trade_units.get_trade_unit_at(0, Time.at(60*5+1))
      }.to raise_error( ArgumentError )
      
      expect {
        trade_units.get_trade_unit_at(0, Time.at(-1))
      }.to raise_error( ArgumentError )
      
      expect {
        trade_units.get_trade_unit_at(3, Time.at(10))
      }.to raise_error( Errors::NotFoundException )
      
    end
  end
  
  context "開始、終了期間と一致するtrade_unitが登録されいない場合" do
    it "期間内のtrade_unitの取得、参照ができる" do
      trade_units = Jiji::Model::Trading::Internal::TradeUnits.create( Time.at(70), Time.at(60*5+10) )
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(70))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(10000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(75))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(10000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(120))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(20000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(121))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(20000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(60*5-1))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(40000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(60*5))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(50000)
      
      trade_unit = trade_units.get_trade_unit_at(0, Time.at(60*5+10))
      expect(trade_unit.pair_id).to eq(0)
      expect(trade_unit.trade_unit).to eq(50000)
      
      expect {
        trade_units.get_trade_unit_at(0, Time.at(69))
      }.to raise_error( ArgumentError )
      
      expect {
        trade_units.get_trade_unit_at(0, Time.at(60*5+11))
      }.to raise_error( ArgumentError )

    end
  end
  
  it "delete で trade_unit を削除できる" do
    expect(Jiji::Model::Trading::Internal::TradeUnit.count).to eq(33)
    
    trade_units = Jiji::Model::Trading::Internal::TradeUnit.delete( Time.at(-50), Time.at(200) )
    expect(Jiji::Model::Trading::Internal::TradeUnit.count).to eq(21)
    
    trade_units = Jiji::Model::Trading::Internal::TradeUnit.delete( Time.at(240), Time.at(300) )
    expect(Jiji::Model::Trading::Internal::TradeUnit.count).to eq(18)
  end
  
end