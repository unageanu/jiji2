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
        .with(:NZDJPY, 50)
        .exactly(3).times
        .and_return( create_order_result("y") )
      positions = create_mock_positions(
        create_mock_position(false, :AUDJPY),
        create_mock_position(false, :NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 82, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2"])

      trader.process_tick(create_tick(89, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2"])

      trader.process_tick(create_tick(88, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2", "-3"])

      trader.process_tick(create_tick(88, 84, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2", "-3"])

      trader.process_tick(create_tick(87, 85, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2", "-3", "-4"])
    end

    it 'open :buy_aud position if the spread is lower than sd,' \
       + 'and close it when the spread is increased.' do

      broker = double('mock broker')
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(3).times
        .and_return( create_order_result )
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 50)
        .exactly(3).times
        .and_return( create_order_result("y") )
      positions = create_mock_positions(
        create_mock_position(true, :AUDJPY),
        create_mock_position(true, :NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2"])
      trader.process_tick(create_tick(88, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2", "-3"])
      trader.process_tick(create_tick(87, 85, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2", "-3", "-4"])

      trader.process_tick(create_tick(87, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2", "-3"])
      trader.process_tick(create_tick(89, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2"])
      trader.process_tick(create_tick(89, 78, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["-2"])
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
        .with(:NZDJPY, 50)
        .exactly(3).times
        .and_return( create_order_result("y") )
      positions = create_mock_positions(
        create_mock_position(false, :AUDJPY),
        create_mock_position(false, :NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

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
        .with(:NZDJPY, 50)
        .exactly(3).times
        .and_return( create_order_result("y") )
      positions = create_mock_positions(
        create_mock_position(true, :AUDJPY),
        create_mock_position(true, :NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

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

    it 'uses coint settings of the time on closing positions' do

      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(2).times
        .and_return( create_order_result )
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(1).times
        .and_return( create_order_result("y") )
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 63)
        .exactly(1).times
        .and_return( create_order_result("y") )
      positions = create_mock_positions(
        create_mock_position(true, :AUDJPY),
        create_mock_position(true, :NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(90, 73, Time.local(2015, 10, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])
      trader.process_tick(create_tick(90, 76, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])
      trader.process_tick(create_tick(90, 80, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(90, 84, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

    it 'enable to change trading price by distance parameter.' do

      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(2).times
        .and_return( create_order_result )
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(2).times
        .and_return( create_order_result("y") )
      positions = create_mock_positions(
        create_mock_position(true, :AUDJPY),
        create_mock_position(true, :NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 0.5, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 76, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])
      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1", "2"])
      trader.process_tick(create_tick(90, 77, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(["1"])
      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

  end

  describe '#restore_state' do

    it 'can restore state from positions' do

      array = [
        create_mock_position(
          false, :AUDJPY, Time.utc(2015, 8, 2), :sell, 80),
        create_mock_position(
          false, :NZDJPY, Time.utc(2015, 8, 2, 0, 0, 10), :buy, 54),

        # index -1
        create_mock_position(
          false, :AUDJPY, Time.utc(2016, 5, 2), :buy, 90),
        create_mock_position(
          false, :NZDJPY, Time.utc(2016, 5, 2, 0, 0, 31), :sell, 80),
          # ignore
        create_mock_position(
          false, :NZDJPY, Time.utc(2016, 5, 2), :buy, 80),  # ignore
        create_mock_position(
          false, :EURJPY, Time.utc(2016, 5, 2), :sell, 80),  # ignore
        create_mock_position(
          false, :NZDJPY, Time.utc(2016, 5, 1, 23, 59, 55), :sell, 86),

        # index -1 (duplication, ignore)
        create_mock_position(
          false, :AUDJPY, Time.utc(2016, 5, 3), :sell, 80),
        create_mock_position(
          false, :NZDJPY, Time.utc(2016, 5, 3, 0, 0, 10), :buy, 74),

        # no pair, ignore
        create_mock_position(
          false, :AUDJPY, Time.utc(2016, 5, 4), :buy, 90),
        create_mock_position(
          false, :NZDJPY, Time.utc(2016, 5, 5), :buy, 90)
      ]

      positions = double('mock positions')
      allow(positions).to receive(:each) do |&block|
        array.each(&block)
      end
      allow(positions).to receive(:find) do |&block|
        array.find(&block)
      end
      broker = double('mock broker')
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)
      expect(trader.positions.keys).to eq(["1", "-2"])

      position = trader.positions["1"]
      expect(position.trade_type).to eq(:sell_a)
      expect(position.spread.round(3)).to eq(52.803)
      expect(position.coint).to eq({
        slope:0.503640515,
        mean:50.550317504,
        sd:1.923043502
      })
      expect(position.distance).to eq(1)
      expect(position.positions[0].pair_name).to eq(:AUDJPY)
      expect(position.positions[0].entered_at).to eq(Time.utc(2015, 8, 2))
      expect(position.positions[0].entry_price).to eq(80)
      expect(position.positions[1].pair_name).to eq(:NZDJPY)
      expect(position.positions[1].entered_at).to eq(
        Time.utc(2015, 8, 2, 0, 0, 10))
      expect(position.positions[1].entry_price).to eq(54)

      position = trader.positions["-2"]
      expect(position.trade_type).to eq(:buy_a)
      expect(position.spread.round(3)).to eq(15.104)
      expect(position.coint).to eq({
        slope:0.870884249,
        mean:17.985573263,
        sd:2.223409486
      })
      expect(position.distance).to eq(1)
      expect(position.positions[0].pair_name).to eq(:AUDJPY)
      expect(position.positions[0].entered_at).to eq(Time.utc(2016, 5, 2))
      expect(position.positions[0].entry_price).to eq(90)
      expect(position.positions[1].pair_name).to eq(:NZDJPY)
      expect(position.positions[1].entered_at).to eq(
        Time.utc(2016, 5, 1, 23, 59, 55))
      expect(position.positions[1].entry_price).to eq(86)
    end

    it 'do nothing if positions are not exists' do
      positions = double('mock positions')
      allow(positions).to receive(:each) do
      end
      broker = double('mock broker')
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)
      expect(trader.positions).to eq({})
    end

  end

  Order = Struct.new(:internal_id)

  def create_order_result(id="x")
    mock = double('mock order result')
    expect(mock).to receive(:trade_opened)
      .and_return( Order.new(id) )
      .at_least(:once)
    mock
  end

  def create_mock_positions(position1, position2)
    mock = double('mock positions')
    allow(mock).to receive(:each) do
    end
    allow(mock).to receive(:[]) do |id|
      id == "x" ? position1 : position2
    end
    mock
  end

end
