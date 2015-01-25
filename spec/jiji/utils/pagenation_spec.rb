# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Utils::Pagenation::Query do
  
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    
    100.times {|i|
      swap = @data_builder.new_swap(i,   1, timestamp=Time.at(i))
      swap.save
      swap = @data_builder.new_swap(i*2, 2, timestamp=Time.at(i))
      swap.save
    }
  end
  
  after(:example) do
    @data_builder.clean
  end
  
  it "絞り込み条件あり、ソート条件あり、0～10件取得" do
    q = Jiji::Utils::Pagenation::Query.new({:pair_id=>1}, {:timestamp=>:asc}, 0, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(10)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(0))
    expect(swaps[9].pair_id).to eq(1)
    expect(swaps[9].timestamp).to eq(Time.at(9))
  end
  
  it "絞り込み条件あり、ソート条件あり、10～20件取得" do
    q = Jiji::Utils::Pagenation::Query.new({:pair_id=>1}, {:timestamp=>:asc}, 10, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(10)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(10))
    expect(swaps[9].pair_id).to eq(1)
    expect(swaps[9].timestamp).to eq(Time.at(19))
  end
  
  it "絞り込み条件あり、ソート条件あり、95～100件取得" do
    q = Jiji::Utils::Pagenation::Query.new({:pair_id=>1}, {:timestamp=>:asc}, 95, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(5)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(95))
    expect(swaps[4].pair_id).to eq(1)
    expect(swaps[4].timestamp).to eq(Time.at(99))
  end
  
  it "絞り込み条件あり、ソート条件あり(逆順)、0～10件取得" do
    q = Jiji::Utils::Pagenation::Query.new({:pair_id=>1}, {:timestamp=>:desc}, 0, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(10)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(99))
    expect(swaps[9].pair_id).to eq(1)
    expect(swaps[9].timestamp).to eq(Time.at(90))
  end
  
  it "絞り込み条件あり、ソート条件あり(逆順)、10～20件取得" do
    q = Jiji::Utils::Pagenation::Query.new({:pair_id=>1}, {:timestamp=>:desc}, 10, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(10)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(89))
    expect(swaps[9].pair_id).to eq(1)
    expect(swaps[9].timestamp).to eq(Time.at(80))
  end
  
  it "絞り込み条件あり、ソート条件あり(逆順)、95～100件取得" do
    q = Jiji::Utils::Pagenation::Query.new({:pair_id=>1}, {:timestamp=>:desc}, 95, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(5)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(4))
    expect(swaps[4].pair_id).to eq(1)
    expect(swaps[4].timestamp).to eq(Time.at(0))
  end
  
  it "絞り込み条件なし、ソート条件あり、0～10件取得" do
    q = Jiji::Utils::Pagenation::Query.new(nil, {:pair_id =>:asc, :timestamp=>:asc}, 0, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(10)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(0))
    expect(swaps[9].pair_id).to eq(1)
    expect(swaps[9].timestamp).to eq(Time.at(9))
  end
  
  it "絞り込み条件なし、ソート条件あり(逆順)、0～10件取得" do
    q = Jiji::Utils::Pagenation::Query.new(nil, {:pair_id =>:desc, :timestamp=>:desc}, 0, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(10)
    expect(swaps[0].pair_id).to eq(2)
    expect(swaps[0].timestamp).to eq(Time.at(99))
    expect(swaps[9].pair_id).to eq(2)
    expect(swaps[9].timestamp).to eq(Time.at(90))
  end
  
  it "絞り込み条件なし、ソート条件なし、0～10件取得" do
    q = Jiji::Utils::Pagenation::Query.new(nil, nil, 0, 10)
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(10)
  end
  
  it "絞り込み条件なし、ソート条件なし、全件取得" do
    q = Jiji::Utils::Pagenation::Query.new
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(200)
  end
  
  it "絞り込み条件あり、ソート条件あり、全件取得" do
    q = Jiji::Utils::Pagenation::Query.new({:pair_id=>1}, {:timestamp=>:asc})
    swaps = q.execute(Jiji::Model::Trading::Internal::Swap).map {|x| x}
    
    expect(swaps.length).to eq(100)
    expect(swaps[0].pair_id).to eq(1)
    expect(swaps[0].timestamp).to eq(Time.at(0))
    expect(swaps[99].pair_id).to eq(1)
    expect(swaps[99].timestamp).to eq(Time.at(99))
  end
  
  
end