# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Rate do
  
  before(:all) do
    @data_builder = Jiji::Test::DataBuilder.new
  end
  
  after(:all) do
    @data_builder.clean
  end
  
  example "mongodbに永続化できる" do
    rate1 = @data_builder.new_rate(1)
    rate1.save
    
    rate2 = @data_builder.new_rate(2)
    rate2.bid_spread = 10
    rate2.ask_spread = -10
    rate2.save
    
    rate1 = Jiji::Model::Trading::Rate.find(rate1._id)
    expect(rate1.pair_id).to eq(1)
    expect(rate1.open_price).to eq(101)
    expect(rate1.close_price).to eq(102)
    expect(rate1.high_price).to eq(111)
    expect(rate1.low_price).to eq(91)
    expect(rate1.buy_swap).to eq(3)
    expect(rate1.sell_swap).to eq(21)
    expect(rate1.timestamp).to eq(DateTime.new(1001, 1, 1, 0, 0, 0))
    expect(rate1.bid_spread).to eq(0)
    expect(rate1.ask_spread).to eq(0)
    
    rate2 = Jiji::Model::Trading::Rate.find(rate2._id)
    expect(rate2.pair_id).to eq(2)
    expect(rate2.open_price).to eq(102)
    expect(rate2.close_price).to eq(103)
    expect(rate2.high_price).to eq(112)
    expect(rate2.low_price).to eq(92)
    expect(rate2.buy_swap).to eq(4)
    expect(rate2.sell_swap).to eq(22)
    expect(rate2.timestamp).to eq(DateTime.new(1002, 1, 1, 0, 0, 0))
    expect(rate2.bid_spread).to eq(0) # スプレッドは永続化されない
    expect(rate2.ask_spread).to eq(0)
  end
  
  example "すべての値が同一である場合、同一とみなされる" do
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
  
  example "clone で複製ができる" do
    rate1 = @data_builder.new_rate(1)
    clone = rate1.clone
    
    expect(rate1 == clone).to eq(true)
    expect(rate1.eql?(clone)).to eq(true)
    expect(rate1.equal?(clone)).to eq(false)
  end
  
  example "4本値のbid,askを取得できる" do
    rate1 = @data_builder.new_rate(1)
    
    # スプレッド未設定の場合、価格そのまま。
    expect(rate1.open.bid).to eq(101)
    expect(rate1.open.ask).to eq(101)
    expect(rate1.close.bid).to eq(102)
    expect(rate1.close.ask).to eq(102)
    expect(rate1.high.bid).to eq(111)
    expect(rate1.high.ask).to eq(111)
    expect(rate1.low.bid).to eq(91)
    expect(rate1.low.ask).to eq(91)
    
    rate1.bid_spread = 10
    rate1.ask_spread = -10
    
    expect(rate1.open.bid).to eq(111)
    expect(rate1.open.ask).to eq(91)
    expect(rate1.close.bid).to eq(112)
    expect(rate1.close.ask).to eq(92)
    expect(rate1.high.bid).to eq(121)
    expect(rate1.high.ask).to eq(101)
    expect(rate1.low.bid).to eq(101)
    expect(rate1.low.ask).to eq(81)
  end
  
end