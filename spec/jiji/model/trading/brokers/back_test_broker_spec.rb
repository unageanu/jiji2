# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Brokers::BackTestBroker do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @data_builder.register_ticks(30, 60*10)
    @repository = Jiji::Model::Trading::TickRepository.new
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  context "全期間を対象に実行する場合" do
    
    let(:broker) {
      Jiji::Model::Trading::Brokers::BackTestBroker.new( 
        "test", Time.at(0), Time.at(60*10*40), @repository )
    }
    
    it "期間内のレートを取得できる" do
      expect( broker.has_next ).to be true
      
      rates = broker.tick
      expect( rates[:EURJPY].bid ).to eq 100
      expect( rates[:EURJPY].ask ).to eq 100.003 
      expect( rates[:EURJPY].buy_swap  ).to be  2
      expect( rates[:EURJPY].sell_swap ).to be 20
      expect( rates[:EURUSD].bid ).to eq 100
      expect( rates[:EURUSD].ask ).to eq 100.003
      expect( rates[:EURUSD].buy_swap  ).to be  2
      expect( rates[:EURUSD].sell_swap ).to be 20
      
      broker.refresh
      expect( broker.has_next ).to be true
      
      rates = broker.tick
      expect( rates[:EURJPY].bid ).to eq 101
      expect( rates[:EURJPY].ask ).to eq 101.003
      expect( rates[:EURJPY].buy_swap  ).to be  3
      expect( rates[:EURJPY].sell_swap ).to be 21
      
      28.times {|i|
        broker.refresh
        expect( broker.has_next ).to be true
        rates = broker.tick
        expect( rates[:EURJPY].bid ).not_to be nil
        expect( rates[:EURJPY].ask ).not_to be nil
        expect( rates[:USDJPY].bid ).not_to be nil
        expect( rates[:USDJPY].ask ).not_to be nil
      }
      
      broker.refresh
      expect( broker.has_next ).to be false
    end
    
    it "refresh を行うまで同じレートが取得される" do
      expect( broker.has_next ).to be true
      
      rates = broker.tick
      expect( rates[:EURJPY].bid ).to eq 100
      expect( rates[:EURJPY].ask ).to eq 100.003
      expect( rates[:EURJPY].buy_swap  ).to be  2
      expect( rates[:EURJPY].sell_swap ).to be 20
      expect( rates[:EURUSD].bid ).to eq 100
      expect( rates[:EURUSD].ask ).to eq 100.003
      expect( rates[:EURUSD].buy_swap  ).to be  2
      expect( rates[:EURUSD].sell_swap ).to be 20
      
      rates = broker.tick
      expect( rates[:EURJPY].bid ).to eq 100
      expect( rates[:EURJPY].ask ).to eq 100.003
      expect( rates[:EURJPY].buy_swap  ).to be  2
      expect( rates[:EURJPY].sell_swap ).to be 20
      expect( rates[:EURUSD].bid ).to eq 100
      expect( rates[:EURUSD].ask ).to eq 100.003
      expect( rates[:EURUSD].buy_swap  ).to be  2
      expect( rates[:EURUSD].sell_swap ).to be 20
    end
    
    it "pair が取得できる" do
      pairs = broker.pairs
      expect( pairs.length ).to be 3
      expect( pairs[0].name ).to be :EURJPY
    end
  end
  
  context "期間の一部を対象に実行する場合" do
    
    let(:broker) {
      Jiji::Model::Trading::Brokers::BackTestBroker.new( 
        "test", Time.at(100), Time.at(60*10*10+100), @repository )
    }
    
    it "期間内のレートを取得できる" do
      expect( broker.has_next ).to be true
      
      rates = broker.tick
      expect( rates[:EURJPY].bid ).to eq 101
      expect( rates[:EURJPY].ask ).to eq 101.003
      expect( rates[:EURJPY].buy_swap  ).to be  3
      expect( rates[:EURJPY].sell_swap ).to be 21
      expect( rates[:EURUSD].bid ).to eq 101
      expect( rates[:EURUSD].ask ).to eq 101.003
      expect( rates[:EURUSD].buy_swap  ).to be  3
      expect( rates[:EURUSD].sell_swap ).to be 21
      
      broker.refresh
      expect( broker.has_next ).to be true
      
      rates = broker.tick
      expect( rates[:EURJPY].bid ).to eq 102
      expect( rates[:EURJPY].ask ).to eq 102.003
      expect( rates[:EURJPY].buy_swap  ).to be  4
      expect( rates[:EURJPY].sell_swap ).to be 22
      
      8.times {|i|
        broker.refresh
        expect( broker.has_next ).to be true
        rates = broker.tick
        expect( rates[:EURJPY].bid ).not_to be nil
        expect( rates[:EURJPY].ask ).not_to be nil
        expect( rates[:USDJPY].bid ).not_to be nil
        expect( rates[:USDJPY].ask ).not_to be nil
      }
      
      broker.refresh
      expect( broker.has_next ).to be false
    end
  end
  
  context "期間内にTickがある場合" do
    
    let(:broker) {
      Jiji::Model::Trading::Brokers::BackTestBroker.new( 
        "test", Time.at(20000), Time.at(30000), @repository )
    }
    
    it "レートは取得できない" do
      expect( broker.has_next ).to be false
    end
    
  end
  
  it "start が end よりも未来の場合、エラーになる" do
    expect{
      Jiji::Model::Trading::Brokers::BackTestBroker.new( 
        "test", Time.at(1000), Time.at(500), @repository )
    }.to raise_error( ArgumentError ) 
  end
    
  
end