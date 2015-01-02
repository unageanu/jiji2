# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Brokers::RMTBroker do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    
    @mock_plugin =  Jiji::Model::Settings::RMTBrokerSetting.available_securities.find {|p| p.plugin_id == :mock}
    @mock_plugin.seed = 0
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  context "プラグインが未設定の場合" do
    
    let(:broker) { @container.lookup( :rmt_broker ) }
    
    it "売買はできない" do
      expect{ broker.positions       }.to raise_error( Errors::NotInitializedException )
      expect{ broker.buy(:EURJPY, 1) }.to raise_error( Errors::NotInitializedException )
      expect{ broker.positions       }.to raise_error( Errors::NotInitializedException )
    end
    
    it "破棄操作は可能" do
      broker.destroy
    end
  end
    
  context "プラグインが設定されている場合" do
    
    shared_examples "プラグインが必要な操作ができる" do

      it "rate,pairが取得できる" do
        
        pairs = broker.available_pairs
        expect( pairs.length ).to be 3
        expect( pairs[0].name ).to be :EURJPY
        expect( pairs[0].trade_unit ).to be 10000
        
        rates = broker.current_rates
        expect( rates[:EURJPY].bid ).to be 145.110
        expect( rates[:EURJPY].ask ).to be 119.128
        expect( rates[:EURJPY].sell_swap ).to be 10
        expect( rates[:EURJPY].buy_swap  ).to be(-20)
        
        @mock_plugin.seed = 1
        rates = broker.current_rates
        expect( rates[:EURJPY].bid ).to be 145.110
        expect( rates[:EURJPY].ask ).to be 119.128
        expect( rates[:EURJPY].sell_swap ).to be 10
        expect( rates[:EURJPY].buy_swap  ).to be(-20)
        
        broker.refresh
        rates = broker.current_rates
        expect( rates[:EURJPY].bid ).to be 146.110
        expect( rates[:EURJPY].ask ).to be 120.128
        expect( rates[:EURJPY].sell_swap ).to be 10
        expect( rates[:EURJPY].buy_swap  ).to be(-20)
      end

      it "売買ができる" do
        broker.buy(:EURJPY, 1)
        broker.sell(:USDJPY, 2)
        broker.positions.each {|k,v|
          broker.commit(v.position_id)
        }
      end
      
      it "破棄操作ができる" do
        broker.destroy
      end
    end
    
    context "プラグインをAPI呼び出しで設定した場合" do
      
      let(:broker) {
        setting = @container.lookup( :rmt_broker_setting ) 
        broker  = @container.lookup( :rmt_broker ) 
        
        setting.set_active_securities(:mock, {})
        broker
      }
      
      it_behaves_like "プラグインが必要な操作ができる"
      
    end
    
    context "設定情報からプラグインを読み込んだ場合" do
      
      let(:broker) {
        setting = @container.lookup( :rmt_broker_setting ) 
        setting.set_active_securities(:mock, {})
        
        # 永続化された設定から再構築する
        @container    = Jiji::Test::TestContainerFactory.instance.new_container
        setting = @container.lookup( :rmt_broker_setting ) 
        setting.setup
        broker = @container.lookup( :rmt_broker ) 
        broker
      }
      
      it_behaves_like "プラグインが必要な操作ができる"
      
    end
  end
end