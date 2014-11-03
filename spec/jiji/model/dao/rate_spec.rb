require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'
require 'jiji/model/dao/rate'

describe Jiji::Model::Dao::Rate do
  
  before(:all) do
    @data_builder = Jiji::Test::DataBuilder.new
  end
  
  after(:all) do
    @data_builder.clean
  end
  
  example "mongodbに永続化できる" do
    rate = Jiji::Model::Dao::Rate.new
    rate.pair  = 1
    rate.open  = 100
    rate.close = 100
    rate.save
  end
  
end