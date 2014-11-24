# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'

describe Jiji::Plugin::Loader, "#load" do

  example "プラグインの一覧を読み込む" do
    container = Jiji::Composing::ContainerFactory.instance.new_container
    loader = container.lookup(:plugin_loader)
    
    loader.load
    
    expect(JIJI::Plugin.get(:test).sort!).to eq ["test1","test2"]
  end
  
end