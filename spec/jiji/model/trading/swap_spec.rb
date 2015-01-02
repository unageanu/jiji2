# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Swaps do
  
  before(:context) do
    @data_builder = Jiji::Test::DataBuilder.new
    
    0.upto(10) {|i|
      (0..2).each {|pair_id|
        s = @data_builder.new_swap(i, pair_id, Time.at(60*i))
        s.save
      }
    }
  end
  
  after(:context) do
    @data_builder.clean
  end
  
  context "開始、終了期間と一致するswapが登録されいる場合" do
    it "期間内のスワップの取得、参照ができる" do
      swaps = Jiji::Model::Trading::Swaps.create( Time.at(0), Time.at(60*5) )
      
      swap = swaps.get_swap_at(0, Time.at(0))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(2)
      expect(swap.sell_swap).to eq(20)
      
      swap = swaps.get_swap_at(1, Time.at(0))
      expect(swap.pair_id).to eq(1)
      expect(swap.buy_swap).to eq(2)
      expect(swap.sell_swap).to eq(20)
      
      swap = swaps.get_swap_at(0, Time.at(10))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(2)
      expect(swap.sell_swap).to eq(20)
      
      swap = swaps.get_swap_at(0, Time.at(60))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(3)
      expect(swap.sell_swap).to eq(21)
      
      swap = swaps.get_swap_at(0, Time.at(61))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(3)
      expect(swap.sell_swap).to eq(21)
      
      swap = swaps.get_swap_at(0, Time.at(60*5-1))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(6)
      expect(swap.sell_swap).to eq(24)
      
      swap = swaps.get_swap_at(0, Time.at(60*5))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(7)
      expect(swap.sell_swap).to eq(25)
      
      expect {
        swaps.get_swap_at(0, Time.at(60*5+1))
      }.to raise_error( ArgumentError )
      
      expect {
        swaps.get_swap_at(0, Time.at(-1))
      }.to raise_error( ArgumentError )
      
      expect {
        swaps.get_swap_at(3, Time.at(10))
      }.to raise_error( Errors::NotFoundException )
      
    end
  end
  
  context "開始、終了期間と一致するswapが登録されいない場合" do
    it "期間内のスワップの取得、参照ができる" do
      swaps = Jiji::Model::Trading::Swaps.create( Time.at(70), Time.at(60*5+10) )
      
      swap = swaps.get_swap_at(0, Time.at(70))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(3)
      expect(swap.sell_swap).to eq(21)
      
      swap = swaps.get_swap_at(0, Time.at(75))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(3)
      expect(swap.sell_swap).to eq(21)
      
      swap = swaps.get_swap_at(0, Time.at(120))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(4)
      expect(swap.sell_swap).to eq(22)
      
      swap = swaps.get_swap_at(0, Time.at(121))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(4)
      expect(swap.sell_swap).to eq(22)
      
      swap = swaps.get_swap_at(0, Time.at(60*5-1))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(6)
      expect(swap.sell_swap).to eq(24)
      
      swap = swaps.get_swap_at(0, Time.at(60*5))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(7)
      expect(swap.sell_swap).to eq(25)
      
      swap = swaps.get_swap_at(0, Time.at(60*5+10))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(7)
      expect(swap.sell_swap).to eq(25)
      
      expect {
        swaps.get_swap_at(0, Time.at(69))
      }.to raise_error( ArgumentError )
      
      expect {
        swaps.get_swap_at(0, Time.at(60*5+11))
      }.to raise_error( ArgumentError )

    end
  end
  
end