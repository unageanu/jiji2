# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::RateSaver do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @saver = Jiji::Model::Trading::Internal::RateSaver.new
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  it "1回目の保存時にswapが必ず保存される" do
    
    expect(Jiji::Model::Trading::Tick.count()).to eq 0
    expect(Jiji::Model::Trading::Swap.count()).to eq 0 
    
    @saver.save( @data_builder.new_tick(1, Time.at(1000)) )
    
    expect(Jiji::Model::Trading::Tick.count()).to eq 1
    expect(Jiji::Model::Trading::Swap.count()).to eq 3
    
  end
  
  it "swapが変更されなければ、保存は行われない" do

    @saver.save( @data_builder.new_tick(1, Time.at(1000)) )
    
    expect(Jiji::Model::Trading::Tick.count()).to eq 1
    expect(Jiji::Model::Trading::Swap.count()).to eq 3
    
    @saver.save( @data_builder.new_tick(1, Time.at(1001)) )

    expect(Jiji::Model::Trading::Tick.count()).to eq 2
    expect(Jiji::Model::Trading::Swap.count()).to eq 3
    
    @saver.save( @data_builder.new_tick(1, Time.at(1002)) )

    expect(Jiji::Model::Trading::Tick.count()).to eq 3
    expect(Jiji::Model::Trading::Swap.count()).to eq 3
    
  end

  it "swapが変更されていれば、保存が行われる" do
    @saver.save( @data_builder.new_tick(1, Time.at(1000)) )
    
    expect(Jiji::Model::Trading::Tick.count()).to eq 1
    expect(Jiji::Model::Trading::Swap.count()).to eq 3
    
    @saver.save( @data_builder.new_tick(2, Time.at(1001)) )

    expect(Jiji::Model::Trading::Tick.count()).to eq 2
    expect(Jiji::Model::Trading::Swap.count()).to eq 6
    
    @saver.save( @data_builder.new_tick(2, Time.at(1002)) )

    expect(Jiji::Model::Trading::Tick.count()).to eq 3
    expect(Jiji::Model::Trading::Swap.count()).to eq 6
    
    @saver.save( @data_builder.new_tick(3, Time.at(1003)) )

    expect(Jiji::Model::Trading::Tick.count()).to eq 4
    expect(Jiji::Model::Trading::Swap.count()).to eq 9
    
  end
  
end