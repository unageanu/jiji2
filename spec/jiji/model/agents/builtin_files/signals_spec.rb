# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/agents/builtin_files/signals'

describe Signals do
  SIGNAL_CLASSES = [
    proc { Signals::MovingAverage.new },
    proc { Signals::WeightedMovingAverage.new },
    proc { Signals::ExponentialMovingAverage.new },
    proc { Signals::BollingerBands.new },
    proc { Signals::BollingerBands.new { |datas| Signals.ema(datas) } },
    proc { Signals::Vector.new },
    proc { Signals::Momentum.new },
    proc { Signals::MACD.new },
    proc { Signals::RSI.new },
    proc { Signals::ROC.new }
  ]
  RATE_SIGNAL_CLASSES = [
    proc { Signals::DMI.new }
  ]

  it '各種シグナルを算出できる' do
    SIGNAL_CLASSES.each do |g|
      signal = g.call
      puts "\n---" + signal.class.to_s
      each { |rate| p signal.next_data(rate) }
    end

    RATE_SIGNAL_CLASSES.each do |g|
      signal = g.call
      puts "\n---" + signal.class.to_s
      each_rates { |rate| p signal.next_data(rate) }
    end
  end

  it '状態の保存と復元ができる' do
    SIGNAL_CLASSES.each do |g|
      test_save_and_restore_state(g, proc { |r| r[:open] })
    end
    RATE_SIGNAL_CLASSES.each do |g|
      test_save_and_restore_state(g)
    end
  end

  def test_save_and_restore_state(generator, converter = nil)
    a = collect_result(generator, converter)
    b = collect_result(generator, converter) do |instance, g|
      state = instance.state
      new_instance = g.call
      new_instance.restore_state(state)
      new_instance
    end
    expect(a).to eq b
  end

  def collect_result(generator, converter = nil, &block)
    signal = generator.call
    each_rates do |rate, i|
      signal = block.call(signal, generator) if block_given? && i % 100 == 0
      signal.next_data(converter ? converter.call(rate) : rate)
    end
  end

  def each
    each_rates { |r, i| yield r[:open], i }
  end

  def each_rates
    i = 0
    CSV.foreach(File.dirname(__FILE__) + '/rate.csv').map do |row|
      rate = {
        open: row[0].to_f, close: row[1].to_f,
        high: row[2].to_f, low:   row[3].to_f
      }
      yield rate, i += 1
    end
  end
end
