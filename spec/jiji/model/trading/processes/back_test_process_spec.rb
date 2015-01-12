# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/mock/mock_back_test'
require 'jiji/model/trading/processes/process_examples'

describe Jiji::Model::Trading::Processes::BackTestProcess do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    
    @job     = Jiji::Test::Mock::MockJob.new
    @logger  = @container.lookup(:logger)
    @process = Jiji::Model::Trading::Processes::BackTestProcess.new( @job, Thread.pool(1), @logger)
  end
  
  after(:example) do
    @process.stop.value
    @data_builder.clean
  end

  it_behaves_like "process の基本操作ができる"
  
end