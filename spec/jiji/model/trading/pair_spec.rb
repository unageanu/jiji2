# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Pairs do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  it "通貨ペアの取得、参照ができる" do
    
    instance = Jiji::Model::Trading::Pairs.instance
    
    pair1 = instance.create_or_get(:EURJPY)
    pair2 = instance.create_or_get(:USDJPY)
    pair3 = instance.create_or_get(:EURJPY)
    
    expect(pair1.name).to eq(:EURJPY)
    expect(pair2.name).to eq(:USDJPY)
    expect(pair3.name).to eq(:EURJPY)
    
    expect(pair1.pair_id == pair2.pair_id).to eq(false)
    expect(pair1.pair_id == pair3.pair_id).to eq(true)
    expect(pair3.pair_id == pair2.pair_id).to eq(false)
    
    pair10 = instance.get_by_id(pair1.pair_id)
    expect(pair10.name).to eq(:EURJPY)
    expect(pair10.pair_id == pair1.pair_id).to eq(true)
    
    pair_not_found = instance.get_by_id(9999)
    expect(pair_not_found).to be nil
    
    instance.reload
    pair4 = instance.create_or_get(:EURJPY)
    pair5 = instance.create_or_get(:EURUSD)
        
    expect(pair4.name).to eq(:EURJPY)
    expect(pair5.name).to eq(:EURUSD)
    
    expect(pair1.pair_id == pair4.pair_id).to eq(true)
    expect(pair1.pair_id == pair5.pair_id).to eq(false)

    pair10 = instance.get_by_id(pair1.pair_id)
    expect(pair10.name).to eq(:EURJPY)
    expect(pair10.pair_id == pair1.pair_id).to eq(true)
    
    pair_not_found = instance.get_by_id(9999)
    expect(pair_not_found).to be nil
  end
  
  it "allで登録済みの通貨ペアを取得できる" do
    instance = Jiji::Model::Trading::Pairs.instance
    instance.reload
    
    expect(instance.all.size).to eq(0)
    
    instance.create_or_get(:EURJPY)
    instance.create_or_get(:USDJPY)
    
    all = instance.all
    expect(all.size).to eq(2)
    expect(all[0].name).to eq(:EURJPY)
    expect(all[1].name).to eq(:USDJPY)
  end
  
end