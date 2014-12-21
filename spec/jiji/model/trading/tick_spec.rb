# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Tick do
  
  before(:all) do
    @data_builder = Jiji::Test::DataBuilder.new
  end
  
  after(:all) do
    @data_builder.clean
  end
  
  it "mongodbに永続化できる" do
    tick1 = @data_builder.new_tick(1)
    tick1.save
    
    tick2 = @data_builder.new_tick(2)
    tick2.save
    
    tick1 = Jiji::Model::Trading::Tick.find(tick1._id)
    expect(tick1.pair_id).to eq(1)
    expect(tick1.bid).to eq(101)
    expect(tick1.ask).to eq(100)
    expect(tick1.buy_swap).to eq(3)
    expect(tick1.sell_swap).to eq(21)
    expect(tick1.timestamp).to eq(DateTime.new(1001, 1, 1, 0, 0, 0))
    
    tick2 = Jiji::Model::Trading::Tick.find(tick2._id)
    expect(tick2.pair_id).to eq(2)
    expect(tick2.bid).to eq(102)
    expect(tick2.ask).to eq(101)
    expect(tick2.buy_swap).to eq(4)
    expect(tick2.sell_swap).to eq(22)
    expect(tick2.timestamp).to eq(DateTime.new(1002, 1, 1, 0, 0, 0))
  end
  
  it "すべての値が同一である場合、同一とみなされる" do
    tick1 = @data_builder.new_tick(1)
    tick2 = @data_builder.new_tick(2)
    
    expect(tick1 == tick2).to eq(false)
    expect(tick1 == tick1).to eq(true)
    expect(tick1 == @data_builder.new_tick(1)).to eq(true)
    
    expect(tick1.eql?(tick2)).to eq(false)
    expect(tick1.eql?(tick1)).to eq(true)
    expect(tick1.eql?(@data_builder.new_tick(1))).to eq(true)
    
    expect(tick1.equal?(tick2)).to eq(false)
    expect(tick1.equal?(tick1)).to eq(true)
    expect(tick1.equal?(@data_builder.new_tick(1))).to eq(false)
  end
  
end