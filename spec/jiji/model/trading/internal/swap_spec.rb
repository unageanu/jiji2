# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::Swaps do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    0.upto(10) do|i|
      (0..2).each do|pair_id|
        s = @data_builder.new_swap(i, pair_id, Time.at(60 * i))
        s.save
      end
    end
  end

  after(:example) do
    @data_builder.clean
  end

  it 'Swapの属性は変更できない' do
    swap = @data_builder.new_swap(0, 0, Time.at(0))
    swap.save

    expect(swap._id).not_to be nil
    expect(swap.pair_id).to eq(0)
    expect(swap.buy_swap).to eq(2)
    expect(swap.sell_swap).to eq(20)
    expect(swap.timestamp).to eq Time.at(0)

    swap.pair_id   = 10
    swap.buy_swap  = 10
    swap.sell_swap = 10
    swap.timestamp = Time.at(10)

    expect(swap._id).not_to be nil
    expect(swap.pair_id).to eq(0)
    expect(swap.buy_swap).to eq(2)
    expect(swap.sell_swap).to eq(20)
    expect(swap.timestamp).to eq Time.at(0)
  end

  context '開始、終了期間と一致するswapが登録されいる場合' do
    it '期間内のスワップの取得、参照ができる' do
      swaps = create_swap(Time.at(0), Time.at(60 * 5))

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

      swap = swaps.get_swap_at(0, Time.at(60 * 5 - 1))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(6)
      expect(swap.sell_swap).to eq(24)

      swap = swaps.get_swap_at(0, Time.at(60 * 5))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(7)
      expect(swap.sell_swap).to eq(25)

      expect do
        swaps.get_swap_at(0, Time.at(60 * 5 + 1))
      end.to raise_error(ArgumentError)

      expect do
        swaps.get_swap_at(0, Time.at(-1))
      end.to raise_error(ArgumentError)

      expect do
        swaps.get_swap_at(3, Time.at(10))
      end.to raise_error(Errors::NotFoundException)
    end
  end

  context '開始、終了期間と一致するswapが登録されいない場合' do
    it '期間内のスワップの取得、参照ができる' do
      swaps = create_swap(Time.at(70), Time.at(60 * 5 + 10))

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

      swap = swaps.get_swap_at(0, Time.at(60 * 5 - 1))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(6)
      expect(swap.sell_swap).to eq(24)

      swap = swaps.get_swap_at(0, Time.at(60 * 5))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(7)
      expect(swap.sell_swap).to eq(25)

      swap = swaps.get_swap_at(0, Time.at(60 * 5 + 10))
      expect(swap.pair_id).to eq(0)
      expect(swap.buy_swap).to eq(7)
      expect(swap.sell_swap).to eq(25)

      expect do
        swaps.get_swap_at(0, Time.at(69))
      end.to raise_error(ArgumentError)

      expect do
        swaps.get_swap_at(0, Time.at(60 * 5 + 11))
      end.to raise_error(ArgumentError)
    end
  end

  it 'delete で swap を削除できる' do
    expect(Jiji::Model::Trading::Internal::Swap.count).to eq(33)

    delete_swap(Time.at(-50), Time.at(200))
    expect(Jiji::Model::Trading::Internal::Swap.count).to eq(21)

    delete_swap(Time.at(240), Time.at(300))
    expect(Jiji::Model::Trading::Internal::Swap.count).to eq(18)
  end

  def create_swap(start_time, end_time)
    Jiji::Model::Trading::Internal::Swaps.create(start_time, end_time)
  end

  def delete_swap(start_time, end_time)
    Jiji::Model::Trading::Internal::Swap.delete(start_time, end_time)
  end
end
