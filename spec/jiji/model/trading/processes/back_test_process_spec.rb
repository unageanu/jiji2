# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/mock/mock_back_test'
require 'jiji/model/trading/processes/process_examples'

describe Jiji::Model::Trading::Processes::BackTestProcess do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    
    @test    = Jiji::Test::Mock::MockBackTest.new
    @logger  = @container.lookup(:logger)
    @process = Jiji::Model::Trading::Processes::BackTestProcess.new( @test, Thread.pool(1), @logger)
    @job     = @process.job
  end
  
  after(:example) do
    @process.stop.value
    @data_builder.clean
  end

  it_behaves_like "process の基本操作ができる"
  
end