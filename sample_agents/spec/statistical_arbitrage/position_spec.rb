# coding: utf-8

require 'sample_agent_test_configuration'
require 'statistical_arbitrage/shared_context'

describe StatisticalArbitrage::Position do
  include_context 'utils for statistical arbitrage'

  before(:example) do
    @broker = double('mock broker')
  end

  describe '#close_if_required' do
    it 'close :buy_aud positions if the spread is higher than sd' do
      expect(@broker).to receive(:sell).with(:AUDJPY, 5000).exactly(6).times
      expect(@broker).to receive(:buy).with(:NZDJPY, 5000).exactly(6).times

      buy_aud = create_buy_aud_position(-1)
      expect(buy_aud.close_if_required(1)).to be true
      buy_aud = create_buy_aud_position(-1)
      expect(buy_aud.close_if_required(2)).to be true

      buy_aud = create_buy_aud_position(-2)
      expect(buy_aud.close_if_required(0)).to be true
      buy_aud = create_buy_aud_position(-2)
      expect(buy_aud.close_if_required(1)).to be true

      buy_aud = create_buy_aud_position(-3)
      expect(buy_aud.close_if_required(-1)).to be true
      buy_aud = create_buy_aud_position(-3)
      expect(buy_aud.close_if_required(0)).to be true
    end

    it 'close :sell_aud positions if the spread is lower than sd' do
      expect(@broker).to receive(:buy).with(:AUDJPY, 5000).exactly(6).times
      expect(@broker).to receive(:sell).with(:NZDJPY, 5000).exactly(6).times

      sell_aud = create_sell_aud_position(1)
      expect(sell_aud.close_if_required(-1)).to be true
      sell_aud = create_sell_aud_position(1)
      expect(sell_aud.close_if_required(-2)).to be true

      sell_aud = create_sell_aud_position(2)
      expect(sell_aud.close_if_required(0)).to be true
      sell_aud = create_sell_aud_position(2)
      expect(sell_aud.close_if_required(-1)).to be true

      sell_aud = create_sell_aud_position(3)
      expect(sell_aud.close_if_required(1)).to be true
      sell_aud = create_sell_aud_position(3)
      expect(sell_aud.close_if_required(0)).to be true
    end

    it 'do nothing if the spread is not higher than sd' do
      buy_aud = create_buy_aud_position(-1)
      expect(buy_aud.close_if_required(0)).to be false
      expect(buy_aud.close_if_required(-1)).to be false
      expect(buy_aud.close_if_required(-2)).to be false
      expect(buy_aud.close_if_required(-3)).to be false
    end

    it 'do nothing if the spread is not lower than sd' do
      sell_aud = create_sell_aud_position(1)
      expect(sell_aud.close_if_required(0)).to be false
      expect(sell_aud.close_if_required(1)).to be false
      expect(sell_aud.close_if_required(2)).to be false
      expect(sell_aud.close_if_required(3)).to be false
    end
  end

  describe '#to_hash' do
    it 'converts a position to hash.' do
      sell_aud = create_sell_aud_position(1)
      expect(sell_aud.to_hash).to eq({
        "trade_type" => :sell_a,
        "index" => 1,
        "positions" => [
          create_mock_position(:AUDJPY, :sell, 5000),
          create_mock_position(:NZDJPY, :buy, 5000)
        ]
      })

      buy_aud = create_buy_aud_position(-2)
      expect(buy_aud.to_hash).to eq({
        "trade_type" => :buy_a,
        "index" => -2,
        "positions" => [
          create_mock_position(:AUDJPY, :buy, 5000),
          create_mock_position(:NZDJPY, :sell, 5000)
        ]
      })
    end
  end

  describe '#from_hash' do
    it 'creates a position from hash.' do
      sell_aud = StatisticalArbitrage::Position.from_hash({
        "trade_type" => :sell_a,
        "index" => 1,
        "positions" => [
          create_mock_position(:AUDJPY, :sell, 5000),
          create_mock_position(:NZDJPY, :buy, 5000)
        ]
      })
      expect(sell_aud.trade_type).to be :sell_a
      expect(sell_aud.index).to be 1
      expect(sell_aud.positions).to eq([
        create_mock_position(:AUDJPY, :sell, 5000),
        create_mock_position(:NZDJPY, :buy, 5000)
      ])

      buy_aud = StatisticalArbitrage::Position.from_hash({
        "trade_type" => :buy_a,
        "index" => -2,
        "positions" => [
          create_mock_position(:AUDJPY, :buy, 5000),
          create_mock_position(:NZDJPY, :sell, 5000)
        ]
      })
      expect(buy_aud.trade_type).to be :buy_a
      expect(buy_aud.index).to be -2
      expect(buy_aud.positions).to eq([
        create_mock_position(:AUDJPY, :buy, 5000),
        create_mock_position(:NZDJPY, :sell, 5000)
      ])
    end
  end

  def create_buy_aud_position(index)
    create_position(:buy_a, index)
  end

  def create_sell_aud_position(index)
    create_position(:sell_a, index)
  end

  def create_position(type, index = 1)
    StatisticalArbitrage::Position.new(type,
      create_mock_positions(type), index, @broker)
  end

  def create_mock_positions(type)
    [
      create_mock_position(:AUDJPY, type==:sell_a ? :sell : :buy, 5000),
      create_mock_position(:NZDJPY, type==:sell_a ? :buy : :sell, 5000)
    ]
  end
end
