# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Rate do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  it "tickから作成できる" do
    
    rate1 = Jiji::Model::Trading::Rate.create_from_tick(
      @data_builder.new_tick(1,   DateTime.new(2014, 1, 1, 0, 0, 0)),  
      @data_builder.new_tick(2,   DateTime.new(2014, 2, 1, 0, 0, 0)),
      @data_builder.new_tick(3,   DateTime.new(2014, 1, 1, 0, 0, 1)),  
      @data_builder.new_tick(10,  DateTime.new(2014, 1, 10, 0, 0, 0)),
      @data_builder.new_tick(-10, DateTime.new(2014, 1, 21, 0, 0, 0))
    )
      
    expect(rate1.pair_id).to eq(:EURJPY)
    expect(rate1.open.bid).to eq(101)
    expect(rate1.open.ask).to eq(100)
    expect(rate1.close.bid).to eq(102)
    expect(rate1.close.ask).to eq(101)
    expect(rate1.high.bid).to eq(110)
    expect(rate1.high.ask).to eq(109)
    expect(rate1.low.bid).to eq(90)
    expect(rate1.low.ask).to eq(89)
    expect(rate1.timestamp).to  eq(DateTime.new(2014, 1, 1, 0, 0, 0))
    expect(rate1.buy_swap).to eq(3)
    expect(rate1.sell_swap).to eq(21)
  end
  
  it "すべての値が同一である場合、同一とみなされる" do
    rate1 = @data_builder.new_rate(1)
    rate2 = @data_builder.new_rate(2)
    
    expect(rate1 == rate2).to eq(false)
    expect(rate1 == rate1).to eq(true)
    expect(rate1 == @data_builder.new_rate(1)).to eq(true)
    
    expect(rate1.eql?(rate2)).to eq(false)
    expect(rate1.eql?(rate1)).to eq(true)
    expect(rate1.eql?(@data_builder.new_rate(1))).to eq(true)
    
    expect(rate1.equal?(rate2)).to eq(false)
    expect(rate1.equal?(rate1)).to eq(true)
    expect(rate1.equal?(@data_builder.new_rate(1))).to eq(false)
  end
  
  it "clone で複製ができる" do
    rate1 = @data_builder.new_rate(1)
    clone = rate1.clone
    
    expect(rate1 == clone).to eq(true)
    expect(rate1.eql?(clone)).to eq(true)
    expect(rate1.equal?(clone)).to eq(false)
  end
  
  it "unionで統合できる" do
    rate1 = Jiji::Model::Trading::Rate.create_from_tick(
      @data_builder.new_tick(1,   DateTime.new(2014, 1, 2, 0, 0, 0)),  
      @data_builder.new_tick(2,   DateTime.new(2014, 2, 1, 0, 0, 0))
    )
    rate2 = Jiji::Model::Trading::Rate.create_from_tick(
      @data_builder.new_tick(4,   DateTime.new(2014, 1, 1, 0, 0, 0)),  
      @data_builder.new_tick(5,   DateTime.new(2014, 3, 1, 0, 0, 0))
    )
    rate3 = Jiji::Model::Trading::Rate.create_from_tick(
      @data_builder.new_tick(6,   DateTime.new(2014, 4, 3, 0, 0, 0)),  
      @data_builder.new_tick(7,   DateTime.new(2014, 1, 1, 0, 0, 0))
    )
    
    rate = Jiji::Model::Trading::Rate.union( rate1, rate2, rate3 ) 
    
    expect(rate.pair_id).to eq(:USDJPY)
    expect(rate.open.bid).to eq(104)
    expect(rate.open.ask).to eq(103)
    expect(rate.close.bid).to eq(106)
    expect(rate.close.ask).to eq(105)
    expect(rate.high.bid).to eq(107)
    expect(rate.high.ask).to eq(106)
    expect(rate.low.bid).to eq(101)
    expect(rate.low.ask).to eq(100)
    expect(rate.timestamp).to  eq(DateTime.new(2014, 1, 1, 0, 0, 0))
    expect(rate.buy_swap).to eq(6)
    expect(rate.sell_swap).to eq(24)
  end
  
  describe "fetch" do
    
    before(:example) do
      0.upto(1000) {|i|
        [:EURJPY,:USDJPY,:EURUSD].each {|pair_id|
          t = @data_builder.new_tick(i%10, Time.at(20*i)) # 20秒ごとに1つ
          t.pair_id = pair_id
          t.save
        }
      }
    end
    
    it "fetch でレート一覧を取得できる" do
      [:EURJPY,:USDJPY,:EURUSD].each {|pair_id|
        rates = Jiji::Model::Trading::Rate.fetch(pair_id, Time.at(12*20), Time.at(72*20))
        
        expect(rates.length).to eq(20)
        expect(rates[0].timestamp).to eq(Time.at(4*60))
        expect(rates[0].open.values ).to eq([pair_id, 102.0, 101.0, 22, 4, Time.at(12*20)])
        expect(rates[0].low.values  ).to eq([pair_id, 102.0, 101.0, 22, 4, Time.at(12*20)])
        expect(rates[0].high.values ).to eq([pair_id, 104.0, 103.0, 24, 6, Time.at(14*20)])
        expect(rates[0].close.values).to eq([pair_id, 104.0, 103.0, 24, 6, Time.at(14*20)])
        
        expect(rates[9].timestamp).to eq(Time.at(13*60))
        expect(rates[9].open.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(39*20)])
        expect(rates[9].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(40*20)])
        expect(rates[9].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(39*20)])
        expect(rates[9].close.values).to eq([pair_id, 101.0, 100.0, 21,  3, Time.at(41*20)])
        
        expect(rates[19].timestamp).to eq(Time.at(23*60))
        expect(rates[19].open.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(69*20)])
        expect(rates[19].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(70*20)])
        expect(rates[19].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(69*20)])
        expect(rates[19].close.values).to eq([pair_id, 101.0, 100.0, 21,  3, Time.at(71*20)])
        
        
        rates = Jiji::Model::Trading::Rate.fetch(pair_id, Time.at(990*20), Time.at(1200*20))

        expect(rates.length).to eq(4)
        expect(rates[0].timestamp).to eq(Time.at(330*60))
        expect(rates[0].open.values ).to eq([pair_id, 100.0,  99.0, 20, 2, Time.at(990*20)])
        expect(rates[0].low.values  ).to eq([pair_id, 100.0,  99.0, 20, 2, Time.at(990*20)])
        expect(rates[0].high.values ).to eq([pair_id, 102.0, 101.0, 22, 4, Time.at(992*20)])
        expect(rates[0].close.values).to eq([pair_id, 102.0, 101.0, 22, 4, Time.at(992*20)])
        
        expect(rates[3].timestamp).to eq(Time.at(333*60))
        expect(rates[3].open.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(999*20)])
        expect(rates[3].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(1000*20)])
        expect(rates[3].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(999*20)])
        expect(rates[3].close.values).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(1000*20)])
        
        
        rates = Jiji::Model::Trading::Rate.fetch(pair_id, Time.at(0*20), Time.at(300*20), :fifteen_minutes)
        
        expect(rates.length).to eq(7)
        expect(rates[0].timestamp).to eq(Time.at(0*60))
        expect(rates[0].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(9*20)])
        expect(rates[0].close.values).to eq([pair_id, 104.0, 103.0, 24,  6, Time.at(44*20)])
        
        expect(rates[6].timestamp).to eq(Time.at(6*60*15))
        expect(rates[6].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(270*20)]) 
        expect(rates[6].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(270*20)])
        expect(rates[6].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(279*20)])
        expect(rates[6].close.values).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(299*20)])
        
        
        rates = Jiji::Model::Trading::Rate.fetch(pair_id, Time.at(0*20), Time.at(600*20), :thirty_minutes)
        
        expect(rates.length).to eq(7)
        expect(rates[0].timestamp).to eq(Time.at(0*60))
        expect(rates[0].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(9*20)])
        expect(rates[0].close.values).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(89*20)])
        
        expect(rates[6].timestamp).to eq(Time.at(6*60*30))
        expect(rates[6].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(540*20)]) 
        expect(rates[6].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(540*20)])
        expect(rates[6].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(549*20)])
        expect(rates[6].close.values).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(599*20)])
        
        
        rates = Jiji::Model::Trading::Rate.fetch(pair_id, Time.at(0*20), Time.at(600*20), :one_hour)

        expect(rates.length).to eq(4)
        expect(rates[0].timestamp).to eq(Time.at(0*60))
        expect(rates[0].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(9*20)])
        expect(rates[0].close.values).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(179*20)])
        
        expect(rates[3].timestamp).to eq(Time.at(3*60*60))
        expect(rates[3].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(540*20)]) 
        expect(rates[3].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(540*20)])
        expect(rates[3].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(549*20)])
        expect(rates[3].close.values).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(599*20)])
        
        
        rates = Jiji::Model::Trading::Rate.fetch(pair_id, Time.at(0*20), Time.at(1200*20), :six_hours)

        expect(rates.length).to eq(1)
        expect(rates[0].timestamp).to eq(Time.at(0*60))
        expect(rates[0].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(9*20)])
        expect(rates[0].close.values).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(1000*20)])
        
        
        rates = Jiji::Model::Trading::Rate.fetch(pair_id, Time.at(0*20), Time.at(1200*20), :one_day)

        expect(rates.length).to eq(1)
        expect(rates[0].timestamp).to eq(Time.at(0*60))
        expect(rates[0].open.values ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].low.values  ).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(0*20)])
        expect(rates[0].high.values ).to eq([pair_id, 109.0, 108.0, 29, 11, Time.at(9*20)])
        expect(rates[0].close.values).to eq([pair_id, 100.0,  99.0, 20,  2, Time.at(1000*20)])
      }
    end
    
  end
  
end