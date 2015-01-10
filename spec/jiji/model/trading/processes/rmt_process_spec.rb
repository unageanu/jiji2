# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/trading/processes/process_examples'

describe Jiji::Model::Trading::Processes::RMTProcess do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    
    @process            = @container.lookup(:rmt_process)
    @job                = @container.lookup(:rmt_job)
    @rmt_broker_setting = @container.lookup(:rmt_broker_setting)
    @rmt_broker_setting.set_active_securities(:mock, {})
    
    @mock_plugin =  Jiji::Test::Mock::MockSecuritiesPlugin.instance
  end
  
  after(:example) do
    @process.stop.value
    @data_builder.clean
  end

  it_behaves_like "process の基本操作ができる"
  
end