# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::RateFetcher do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    register_ticks
    
    @fetcher = Jiji::Model::Trading::Internal::RateFetcher.new
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  def register_ticks
    0.upto(1000) {|i|
      t = @data_builder.new_tick(i%10, Time.at(20*i)) # 20秒ごとに1つ
      t.save
      
      t.each {|v|
        swap = Jiji::Model::Trading::Swap.new {|s|
          s.pair_id   = Jiji::Model::Trading::Pairs.instance.create_or_get(v[0]).pair_id
          s.buy_swap  = v[1].buy_swap
          s.sell_swap = v[1].sell_swap
          s.timestamp = t.timestamp
        }
        swap.save
      }
    }
  end
  
  it "fetch でレート一覧を取得できる" do
    [:EURJPY,:USDJPY,:EURUSD].each {|pair_id|
      rates = @fetcher.fetch(pair_id, Time.at(12*20), Time.at(72*20))
      
      expect(rates.length).to eq(20)
      expect(rates[0].timestamp).to eq(Time.at(4*60))
      expect(rates[0].open.values ).to eq([ 102.0, 101.0, 4, 22 ])
      expect(rates[0].low.values  ).to eq([ 102.0, 101.0, 4, 22 ])
      expect(rates[0].high.values ).to eq([ 104.0, 103.0, 6, 24 ])
      expect(rates[0].close.values).to eq([ 104.0, 103.0, 6, 24 ])
      
      expect(rates[9].timestamp).to eq(Time.at(13*60))
      expect(rates[9].open.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[9].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[9].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[9].close.values).to eq([ 101.0, 100.0,  3, 21 ])
      
      expect(rates[19].timestamp).to eq(Time.at(23*60))
      expect(rates[19].open.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[19].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[19].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[19].close.values).to eq([ 101.0, 100.0,  3, 21 ])
      
      
      rates = @fetcher.fetch(pair_id, Time.at(990*20), Time.at(1200*20))

      expect(rates.length).to eq(4)
      expect(rates[0].timestamp).to eq(Time.at(330*60))
      expect(rates[0].open.values ).to eq([ 100.0,  99.0, 2, 20 ])
      expect(rates[0].low.values  ).to eq([ 100.0,  99.0, 2, 20 ])
      expect(rates[0].high.values ).to eq([ 102.0, 101.0, 4, 22 ])
      expect(rates[0].close.values).to eq([ 102.0, 101.0, 4, 22 ])
      
      expect(rates[3].timestamp).to eq(Time.at(333*60))
      expect(rates[3].open.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[3].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[3].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[3].close.values).to eq([ 100.0,  99.0,  2, 20 ])
      
      
      rates = @fetcher.fetch(pair_id, Time.at(0*20), Time.at(300*20), :fifteen_minutes)
      
      expect(rates.length).to eq(7)
      expect(rates[0].timestamp).to eq(Time.at(0*60))
      expect(rates[0].open.values ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[0].close.values).to eq([ 104.0, 103.0,  6, 24 ])
      
      expect(rates[6].timestamp).to eq(Time.at(6*60*15))
      expect(rates[6].open.values ).to eq([ 100.0,  99.0,  2, 20 ]) 
      expect(rates[6].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[6].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[6].close.values).to eq([ 109.0, 108.0, 11, 29 ])
      
      
      rates = @fetcher.fetch(pair_id, Time.at(0*20), Time.at(600*20), :thirty_minutes)
      
      expect(rates.length).to eq(7)
      expect(rates[0].timestamp).to eq(Time.at(0*60))
      expect(rates[0].open.values ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[0].close.values).to eq([ 109.0, 108.0, 11, 29 ])
      
      expect(rates[6].timestamp).to eq(Time.at(6*60*30))
      expect(rates[6].open.values ).to eq([ 100.0,  99.0,  2, 20 ]) 
      expect(rates[6].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[6].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[6].close.values).to eq([ 109.0, 108.0, 11, 29 ])
      
      
      rates = @fetcher.fetch(pair_id, Time.at(0*20), Time.at(600*20), :one_hour)

      expect(rates.length).to eq(4)
      expect(rates[0].timestamp).to eq(Time.at(0*60))
      expect(rates[0].open.values ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[0].close.values).to eq([ 109.0, 108.0, 11, 29 ])
      
      expect(rates[3].timestamp).to eq(Time.at(3*60*60))
      expect(rates[3].open.values ).to eq([ 100.0,  99.0,  2, 20 ]) 
      expect(rates[3].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[3].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[3].close.values).to eq([ 109.0, 108.0, 11, 29 ])
      
      
      rates = @fetcher.fetch(pair_id, Time.at(0*20), Time.at(1200*20), :six_hours)

      expect(rates.length).to eq(1)
      expect(rates[0].timestamp).to eq(Time.at(0*60))
      expect(rates[0].open.values ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[0].close.values).to eq([ 100.0,  99.0,  2, 20 ])
      
      
      rates = @fetcher.fetch(pair_id, Time.at(0*20), Time.at(1200*20), :one_day)

      expect(rates.length).to eq(1)
      expect(rates[0].timestamp).to eq(Time.at(0*60))
      expect(rates[0].open.values ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].low.values  ).to eq([ 100.0,  99.0,  2, 20 ])
      expect(rates[0].high.values ).to eq([ 109.0, 108.0, 11, 29 ])
      expect(rates[0].close.values).to eq([ 100.0,  99.0,  2, 20 ])
    }
    
  end
  
end