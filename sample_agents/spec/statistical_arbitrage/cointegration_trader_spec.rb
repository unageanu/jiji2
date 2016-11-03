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
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 50)
        .exactly(3).times
      positions = create_mock_positions(
        create_mock_position(:AUDJPY),
        create_mock_position(:NZDJPY)
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
      expect(trader.positions.keys).to eq(['-2'])

      trader.process_tick(create_tick(89, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2'])

      trader.process_tick(create_tick(88, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2', '-3'])

      trader.process_tick(create_tick(88, 84, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2', '-3'])

      trader.process_tick(create_tick(87, 85, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2', '-3', '-4'])
    end

    it 'open :buy_aud position if the spread is lower than sd,' \
       + 'and close it when the spread is increased.' do
      broker = double('mock broker')
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(3).times
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 50)
        .exactly(3).times
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(3).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(3).times
      positions = create_mock_positions(
        create_mock_position(:AUDJPY),
        create_mock_position(:NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2'])
      trader.process_tick(create_tick(88, 83, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2', '-3'])
      trader.process_tick(create_tick(87, 85, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2', '-3', '-4'])

      trader.process_tick(create_tick(87, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2', '-3'])
      trader.process_tick(create_tick(89, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2'])
      trader.process_tick(create_tick(89, 78, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['-2'])
      trader.process_tick(create_tick(90, 78, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

    it 'open :sell_aud position if the spread is higher than sd' do
      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(3).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(3).times
      positions = create_mock_positions(
        create_mock_position(:AUDJPY),
        create_mock_position(:NZDJPY)
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
      expect(trader.positions.keys).to eq(['1'])

      trader.process_tick(create_tick(91, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])

      trader.process_tick(create_tick(92, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))

      trader.process_tick(create_tick(92, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))

      trader.process_tick(create_tick(93, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2 3))
    end

    it 'open :sell_aud position if the spread is higher than sd,' \
       + ' and close it when the spread is reduced.' do
      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(3).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(3).times
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(3).times
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 50)
        .exactly(3).times
      positions = create_mock_positions(
        create_mock_position(:AUDJPY),
        create_mock_position(:NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(92, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))
      trader.process_tick(create_tick(93, 71, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2 3))

      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 79, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

    it 'uses coint settings of the time on closing positions' do
      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(2).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(1).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 63)
        .exactly(1).times
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(2).times
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 50)
        .exactly(1).times
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 63)
        .exactly(1).times
      positions = create_mock_positions(
        create_mock_position(:AUDJPY),
        create_mock_position(:NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 1, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 73, Time.local(2015, 10, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))
      trader.process_tick(create_tick(90, 76, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))
      trader.process_tick(create_tick(90, 80, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 84, Time.local(2016, 2, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end

    it 'enable to change trading price by distance parameter.' do
      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(2).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(2).times
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(2).times
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 50)
        .exactly(2).times
      positions = create_mock_positions(
        create_mock_position(:AUDJPY),
        create_mock_position(:NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 0.5, broker)

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 76, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))
      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))
      trader.process_tick(create_tick(90, 77, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
    end
  end

  describe '#save_state' do
    it 'can extract states of positions' do
      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(2).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(2).times

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 0.5, broker)
      expect(trader.save_state).to eq([])

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 76, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))

      expect(trader.save_state).to eq([{
        "trade_type"=>:sell_a,
        "index"=>1,
        "positions"=>[
          {"pair"=>:AUDJPY, "units"=>100, "sell_or_buy"=>:sell},
           {"pair"=>:NZDJPY, "units"=>50, "sell_or_buy"=>:buy}
        ]
      }, {
        "trade_type"=>:sell_a,
        "index"=>2,
        "positions"=>[
          {"pair"=>:AUDJPY, "units"=>100, "sell_or_buy"=>:sell},
          {"pair"=>:NZDJPY, "units"=>50, "sell_or_buy"=>:buy}
        ]
      }])
    end
  end

  describe '#restore_state' do
    it 'can restore state from positions' do
      broker = double('mock broker')
      expect(broker).to receive(:sell)
        .with(:AUDJPY, 100)
        .exactly(2).times
      expect(broker).to receive(:buy)
        .with(:NZDJPY, 50)
        .exactly(2).times
      expect(broker).to receive(:buy)
        .with(:AUDJPY, 100)
        .exactly(2).times
      expect(broker).to receive(:sell)
        .with(:NZDJPY, 50)
        .exactly(2).times
      positions = create_mock_positions(
        create_mock_position(:AUDJPY),
        create_mock_position(:NZDJPY)
      )
      allow(broker).to receive(:positions).and_return(positions)

      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 0.5, broker)
      trader.restore_state([])
      expect(trader.positions.keys).to eq([])

      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
      trader.process_tick(create_tick(90, 76, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 74, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))

      states = trader.save_state
      trader = StatisticalArbitrage::CointegrationTrader.new(
        :AUDJPY, :NZDJPY, 100, 0.5, broker)
      trader.restore_state(states)
      expect(trader.positions.keys).to eq(%w(1 2))

      trader.process_tick(create_tick(90, 75, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(%w(1 2))
      trader.process_tick(create_tick(90, 77, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq(['1'])
      trader.process_tick(create_tick(90, 80, Time.local(2015, 5, 1, 12)))
      expect(trader.positions.keys).to eq([])
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

  def create_order_result(id = 'x')
    mock = double('mock order result')
    expect(mock).to receive(:trade_opened)
      .and_return(Order.new(id))
      .at_least(:once)
    mock
  end

  def create_mock_positions(position1, position2)
    mock = double('mock positions')
    allow(mock).to receive(:each) do
    end
    allow(mock).to receive(:[]) do |id|
      id == 'x' ? position1 : position2
    end
    mock
  end
end
