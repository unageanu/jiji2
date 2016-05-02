# coding: utf-8

require 'sample_agent_test_configuration'
require 'statistical_arbitrage/shared_context'

describe StatisticalArbitrage::Position do
  include_context 'utils for statistical arbitrage'

  describe '#close_if_required' do
    it 'close :buy_aud positions if the spread is higher than sd' do
      buy_aud = create_buy_aud_position(true)
      expect(buy_aud.close_if_required(create_tick(70, 60))).to be true

      buy_aud = create_buy_aud_position(true)
      expect(buy_aud.close_if_required(create_tick(68, 57))).to be true

      buy_aud = create_buy_aud_position(true)
      expect(buy_aud.close_if_required(create_tick(69, 58))).to be true
    end

    it 'close :sell_aud positions if the spread is lower than sd' do
      sell_aud = create_sell_aud_position(true)
      expect(sell_aud.close_if_required(create_tick(66, 60))).to be true

      sell_aud = create_sell_aud_position(true)
      expect(sell_aud.close_if_required(create_tick(68, 63))).to be true

      sell_aud = create_sell_aud_position(true)
      expect(sell_aud.close_if_required(create_tick(67, 62))).to be true
    end

    it 'do nothing if the spread is not higher than sd' do
      buy_aud = create_buy_aud_position(false)
      expect(buy_aud.close_if_required(create_tick(68,  60))).to be false
      expect(buy_aud.close_if_required(create_tick(68,  59))).to be false
      expect(buy_aud.close_if_required(create_tick(68,  58))).to be false
      expect(buy_aud.close_if_required(create_tick(68,  61))).to be false
      expect(buy_aud.close_if_required(create_tick(68,  70))).to be false
      expect(buy_aud.close_if_required(create_tick(68,  80))).to be false
      expect(buy_aud.close_if_required(create_tick(69,  60))).to be false
      expect(buy_aud.close_if_required(create_tick(67,  60))).to be false
      expect(buy_aud.close_if_required(create_tick(60,  60))).to be false
    end

    it 'do nothing if the spread is not lower than sd' do
      sell_aud = create_sell_aud_position(false)
      expect(sell_aud.close_if_required(create_tick(68,  60))).to be false
      expect(sell_aud.close_if_required(create_tick(68,  61))).to be false
      expect(sell_aud.close_if_required(create_tick(68,  62))).to be false
      expect(sell_aud.close_if_required(create_tick(68,  59))).to be false
      expect(sell_aud.close_if_required(create_tick(68,  55))).to be false
      expect(sell_aud.close_if_required(create_tick(68,  40))).to be false
      expect(sell_aud.close_if_required(create_tick(67,  60))).to be false
      expect(sell_aud.close_if_required(create_tick(69,  60))).to be false
      expect(sell_aud.close_if_required(create_tick(80,  60))).to be false
    end
  end

  def create_buy_aud_position(expect_to_receive_close,
    spread=20, coint={slope:0.8, mean:20, sd:2})
    create_position(:buy_aud, expect_to_receive_close, spread, coint)
  end

  def create_sell_aud_position(expect_to_receive_close,
    spread=20, coint={slope:0.8, mean:20, sd:2})
    create_position(:sell_aud, expect_to_receive_close, spread, coint)
  end

  def create_position(type, expect_to_receive_close,
    spread=20, coint={slope:0.8, mean:20, sd:2})
    StatisticalArbitrage::Position.new(type, spread, coint,
      create_mock_positions(expect_to_receive_close))
  end

  def create_mock_positions(expect_to_receive_close)
    [
      create_mock_position(expect_to_receive_close),
      create_mock_position(expect_to_receive_close)
    ]
  end

end
