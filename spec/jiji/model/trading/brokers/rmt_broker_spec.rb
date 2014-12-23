# coding: utf-8

require 'jiji/test/test_configuration'

RSpec.configure do |c|
  c.include Jiji::Model::Trading::Brokers
  c.include Jiji::Errors
end

describe Jiji::Model::Trading::Brokers::RMTBroker do
  
  RMTBroker = Jiji::Model::Trading::Brokers::RMTBroker
  Errors    = Jiji::Errors
  
  before(:all) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
  end
  
  after(:all) do
    @data_builder.clean
  end
  
  context "プラグインが未設定の場合" do
    
    let(:broker) { @container.lookup( :rmt_broker ) }
    
    it "売買はできない" do
      expect{ broker.positions                 }.to raise_error( Errors::NotInitializedException )
      expect{ broker.buy(:EURJPY, 1)           }.to raise_error( Errors::NotInitializedException )
      expect{ broker.positions                 }.to raise_error( Errors::NotInitializedException )
    end
    
    it "破棄操作は可能" do
      broker.destroy
    end
  end
    
  context "プラグインが設定されている場合" do
    
    shared_examples "プラグインが必要な操作ができる" do

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
        broker = @container.lookup( :rmt_broker ) 
        broker
      }
      
      it_behaves_like "プラグインが必要な操作ができる"
      
    end
  end
end