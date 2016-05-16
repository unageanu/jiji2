# coding: utf-8

require 'sample_agent_test_configuration'
require 'statistical_arbitrage/shared_context'

describe StatisticalArbitrage::Position do
  include_context 'utils for statistical arbitrage'

  describe '#close_if_required' do
    it 'close :buy_aud positions if the spread is higher than sd' do
      buy_aud = create_buy_aud_position(true, -1)
      expect(buy_aud.close_if_required(1)).to be true
      buy_aud = create_buy_aud_position(true, -1)
      expect(buy_aud.close_if_required(2)).to be true

      buy_aud = create_buy_aud_position(true, -2)
      expect(buy_aud.close_if_required(0)).to be true
      buy_aud = create_buy_aud_position(true, -2)
      expect(buy_aud.close_if_required(1)).to be true

      buy_aud = create_buy_aud_position(true, -3)
      expect(buy_aud.close_if_required(-1)).to be true
      buy_aud = create_buy_aud_position(true, -3)
      expect(buy_aud.close_if_required(0)).to be true
    end

    it 'close :sell_aud positions if the spread is lower than sd' do
      sell_aud = create_sell_aud_position(true, 1)
      expect(sell_aud.close_if_required(-1)).to be true
      sell_aud = create_sell_aud_position(true, 1)
      expect(sell_aud.close_if_required(-2)).to be true

      sell_aud = create_sell_aud_position(true, 2)
      expect(sell_aud.close_if_required(0)).to be true
      sell_aud = create_sell_aud_position(true, 2)
      expect(sell_aud.close_if_required(-1)).to be true

      sell_aud = create_sell_aud_position(true, 3)
      expect(sell_aud.close_if_required(1)).to be true
      sell_aud = create_sell_aud_position(true, 3)
      expect(sell_aud.close_if_required(0)).to be true
    end

    it 'do nothing if the spread is not higher than sd' do
      buy_aud = create_buy_aud_position(false, -1)
      expect(buy_aud.close_if_required(0)).to be false
      expect(buy_aud.close_if_required(-1)).to be false
      expect(buy_aud.close_if_required(-2)).to be false
      expect(buy_aud.close_if_required(-3)).to be false
    end

    it 'do nothing if the spread is not lower than sd' do
      sell_aud = create_sell_aud_position(false, 1)
      expect(sell_aud.close_if_required(0)).to be false
      expect(sell_aud.close_if_required(1)).to be false
      expect(sell_aud.close_if_required(2)).to be false
      expect(sell_aud.close_if_required(3)).to be false
    end
  end

  def create_buy_aud_position(expect_to_receive_close,
    index, spread=20, coint={slope:0.8, mean:20, sd:2})
    create_position(:buy_a, expect_to_receive_close, spread, coint, index)
  end

  def create_sell_aud_position(expect_to_receive_close,
    index, spread=20, coint={slope:0.8, mean:20, sd:2})
    create_position(:sell_a, expect_to_receive_close, spread, coint, index)
  end

  def create_position(type, expect_to_receive_close,
    spread=20, coint={slope:0.8, mean:20, sd:2}, index)
    StatisticalArbitrage::Position.new(type, spread, coint,
      create_mock_positions(expect_to_receive_close), index, 1)
  end

  def create_mock_positions(expect_to_receive_close)
    [
      create_mock_position(expect_to_receive_close, :AUDJPY),
      create_mock_position(expect_to_receive_close, :NZDJPY)
    ]
  end

end
