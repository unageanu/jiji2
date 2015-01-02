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
  
  it "mongodbに永続化できる" do
    
    pair_and_values = {
      :EURJPY => @data_builder.new_tick_value(1),
      :USDJPY => @data_builder.new_tick_value(2),
      :EURUSD => @data_builder.new_tick_value(3) 
    }
    
    tick = Jiji::Model::Trading::Tick.create( pair_and_values, Time.at(1) )
    
    expect(tick.timestamp).to eq(Time.at(1))
    expect(tick[:EURJPY].bid).to eq(101.0)
    expect(tick[:EURJPY].ask).to eq(100.0)
    expect(tick[:EURJPY].buy_swap).to eq(3)
    expect(tick[:EURJPY].sell_swap).to eq(21)
    
    expect(tick[:USDJPY].bid).to eq(102.0)
    expect(tick[:USDJPY].ask).to eq(101.0)
    expect(tick[:USDJPY].buy_swap).to eq(4)
    expect(tick[:USDJPY].sell_swap).to eq(22)

    expect(tick[:EURUSD].bid).to eq(103.0)
    expect(tick[:EURUSD].ask).to eq(102.0)
    expect(tick[:EURUSD].buy_swap).to eq(5)
    expect(tick[:EURUSD].sell_swap).to eq(23)


    tick.save
    
    expect(tick.timestamp).to eq(Time.at(1))
    expect(tick[:EURJPY].bid).to eq(101.0)
    expect(tick[:EURJPY].ask).to eq(100.0)
    expect(tick[:EURJPY].buy_swap).to eq(3)
    expect(tick[:EURJPY].sell_swap).to eq(21)
    
    expect(tick[:USDJPY].bid).to eq(102.0)
    expect(tick[:USDJPY].ask).to eq(101.0)
    expect(tick[:USDJPY].buy_swap).to eq(4)
    expect(tick[:USDJPY].sell_swap).to eq(22)

    expect(tick[:EURUSD].bid).to eq(103.0)
    expect(tick[:EURUSD].ask).to eq(102.0)
    expect(tick[:EURUSD].buy_swap).to eq(5)
    expect(tick[:EURUSD].sell_swap).to eq(23)
    
    
    eur_jpy = Jiji::Model::Trading::Pairs.instance.create_or_get(:EURJPY)
    usd_jpy = Jiji::Model::Trading::Pairs.instance.create_or_get(:USDJPY)
    eur_usd = Jiji::Model::Trading::Pairs.instance.create_or_get(:EURUSD)

    tick = Jiji::Model::Trading::Tick.find(tick._id)
    tick.swaps = {
      eur_jpy.pair_id => @data_builder.new_swap(1, eur_jpy.pair_id, Time.at(1)),
      usd_jpy.pair_id => @data_builder.new_swap(2, usd_jpy.pair_id, Time.at(1)),
      eur_usd.pair_id => @data_builder.new_swap(3, eur_usd.pair_id, Time.at(1))
    }
   
    expect(tick.timestamp).to eq(Time.at(1))
    expect(tick[:EURJPY].bid).to eq(101.0)
    expect(tick[:EURJPY].ask).to eq(100.0)
    expect(tick[:EURJPY].buy_swap).to eq(3)
    expect(tick[:EURJPY].sell_swap).to eq(21)
    
    expect(tick[:USDJPY].bid).to eq(102.0)
    expect(tick[:USDJPY].ask).to eq(101.0)
    expect(tick[:USDJPY].buy_swap).to eq(4)
    expect(tick[:USDJPY].sell_swap).to eq(22)

    expect(tick[:EURUSD].bid).to eq(103.0)
    expect(tick[:EURUSD].ask).to eq(102.0)
    expect(tick[:EURUSD].buy_swap).to eq(5)
    expect(tick[:EURUSD].sell_swap).to eq(23)
    
  end
  
  # describe "fetch" do
#     
    # before(:example) do
      # Jiji::Model::Trading::Tick.create_indexes
      # 0.upto(1000) {|i|
        # values = {}
        # 0.upto(14) {|j|
          # values[j] = @data_builder.new_tick_value(i%10)
        # }
        # t = Jiji::Model::Trading::Tick.create(values, Time.at(20*i))
        # t.save
      # }
    # end
#     
    # it "aaa" do
#       
    # end
#     
  # end
  
end