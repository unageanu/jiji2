# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Settings::RMTBrokerSetting do
  
  RMTBrokerSetting = Jiji::Model::Settings::RMTBrokerSetting
  Errors           = Jiji::Errors
    
  before(:all) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @setting = @container.lookup(:rmt_broker_setting)
  end
  
  after(:all) do
    @data_builder.clean
  end
  
  it "利用可能なプラグイン一覧を取得できる" do
    list = RMTBrokerSetting.available_securities
    
    expect( list.size ).to be > 0
    expect( list.find {|i| i.plugin_id == :mock } ).not_to be nil 
  end
  
  it "プラグインの設定定義情報を取得できる" do
    defs = RMTBrokerSetting.get_configuration_definitions(:mock)
    expect(defs.length).to be 3
    
    defs = RMTBrokerSetting.get_configuration_definitions(:mock2)
    expect(defs.length).to be 3
  end

  it "アクティブなプラグインを設定できる" do
    plugin = nil
    @setting.on_setting_changed {|key, event|
      plugin = event[:value]
    }
    
    expect(@setting.active_securities).to be nil
    
    @setting.set_active_securities(:mock,  {"a"=>"aa","b"=>"bb"})
    
    expect(@setting.active_securities.plugin_id).to eq :mock
    expect(@setting.active_securities.props).to eq({"a"=>"aa","b"=>"bb"})
    expect(plugin.plugin_id).to eq :mock
    expect(plugin.props).to eq({"a"=>"aa","b"=>"bb"})
    
    @setting.set_active_securities(:mock2, {"a"=>"aa","c"=>"cc"})
    
    expect(@setting.active_securities.plugin_id).to eq :mock2
    expect(@setting.active_securities.props).to eq({"a"=>"aa","c"=>"cc"})
    expect(plugin.plugin_id).to eq :mock2
    expect(plugin.props).to eq({"a"=>"aa","c"=>"cc"})
  end

  it "プラグインの設定情報を取得できる" do
    @setting.set_active_securities(:mock,  {"a"=>"aa","b"=>"bb"})
    @setting.set_active_securities(:mock2, {"a"=>"aa","c"=>"cc"})
    
    expect(@setting.get_configurations(:mock)).to eq({"a"=>"aa","b"=>"bb"})
    expect(@setting.get_configurations(:mock2)).to eq({"a"=>"aa","c"=>"cc"})
  end
  
  it "設定情報を永続化できる" do
    @setting.set_active_securities(:mock,  {"a"=>"aa","b"=>"bb"})
    @setting.set_active_securities(:mock2, {"a"=>"aa","c"=>"cc"})
    
    @container = Jiji::Test::TestContainerFactory.instance.new_container
    @setting   = @container.lookup(:rmt_broker_setting)
    expect(@setting.active_securities.plugin_id).to eq :mock2
    expect(@setting.active_securities.props).to eq({"a"=>"aa","c"=>"cc"})
  end
  
  context "プラグインが存在しない場合" do
    it "設定定義情報取得はエラー" do
      expect {
        RMTBrokerSetting.get_configuration_definitions(:not_found)
      }.to raise_error( Errors::NotFoundException )
    end
    it "設定値取得はエラー" do
      expect {
        @setting.get_configurations(:not_found)
      }.to raise_error( Errors::NotFoundException )
    end
    it "プラグインの設定はエラー" do
      expect {
        @setting.set_active_securities(:not_found, {"a"=>"aa","c"=>"cc"})
      }.to raise_error( Errors::NotFoundException )
    end
  end

end