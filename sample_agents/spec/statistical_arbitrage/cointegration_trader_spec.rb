# coding: utf-8

require 'sample_agent_test_configuration'
require 'statistical_arbitrage/shared_context'

describe StatisticalArbitrage::CointegrationTrader do
  include_context 'utils for statistical arbitrage'

  describe '#process_tick' do

    it 'open :buy_aud position if the spread is lower than sd' do

      broker = double('mock broker')
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      positions = { "x" => create_mock_position(false) }
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 82, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1"])

      trader.process_tick(create_tick(89, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1"])

      trader.process_tick(create_tick(88, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1", "-2"])

      trader.process_tick(create_tick(88, 84, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1", "-2"])

      trader.process_tick(create_tick(87, 85, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1", "-2", "-3"])
    end

    it 'open :buy_aud position if the spread is lower than sd,' \
       + 'and close it when the spread is increased.' do

      broker = double('mock broker')
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      positions = { "x" => create_mock_position(true) }
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1"])
      trader.process_tick(create_tick(88, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1", "-2"])
      trader.process_tick(create_tick(87, 85, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1", "-2", "-3"])

      trader.process_tick(create_tick(87, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1", "-2"])
      trader.process_tick(create_tick(89, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1"])
      trader.process_tick(create_tick(89, 78, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-1"])
      trader.process_tick(create_tick(90, 78, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

    it 'open :sell_aud position if the spread is higher than sd' do

      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      positions = { "x" => create_mock_position(false) }
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 78, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 82, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])

      trader.process_tick(create_tick(91, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])

      trader.process_tick(create_tick(92, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])

      trader.process_tick(create_tick(92, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])

      trader.process_tick(create_tick(93, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2", "3"])
    end

    it 'open :sell_aud position if the spread is higher than sd,' \
       + ' and close it when the spread is reduced.' do

      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      positions = { "x" => create_mock_position(true) }
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(92, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])
      trader.process_tick(create_tick(93, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2", "3"])

      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(90, 79, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

    it 'uses coint settings of the time that created positions' \
       + 'on closing positions' do

      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(2).times
        .and_return( create_order_result )
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 100)
        .exactly(2).times
        .and_return( create_order_result )
      positions = { "x" => create_mock_position(true) }
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(90, 73, Time.local(2015, 10, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])
      trader.process_tick(create_tick(90, 76, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])
      trader.process_tick(create_tick(90, 80, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

  end

  Order = Struct.new(:internal_id)

  def create_order_result
    mock = double('mock order result')
    expect(mock).to receive(:trade_opened)
      .and_return( Order.new("x") )
      .at_least(:once)
    mock
  end

end
