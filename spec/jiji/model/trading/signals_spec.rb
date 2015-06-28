# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/trading/signals'

describe Signals do
  Rate = Struct.new(:start, :end, :max, :min)

  it '各種シグナルを算出できる' do
    signals = [
      Signals::MovingAverage.new,
      Signals::WeightedMovingAverage.new,
      Signals::ExponentialMovingAverage.new,
      Signals::BollingerBands.new,
      Signals::BollingerBands.new { |datas| Signals.ema(datas) },
      Signals::Vector.new,
      Signals::Momentum.new,
      Signals::MACD.new,
      Signals::RSI.new,
      Signals::ROC.new
    ]
    signals.each do |s|
      puts "\n---" + s.class.to_s
      each { |rate| p s.next_data(rate) }
    end

    signals = [
      Signals::DMI.new
    ]
    signals.each do |s|
      puts "\n---" + s.class.to_s
      each_rates { |rate| p s.next_data(rate) }
    end
  end

  def each
    each_rates { |r| yield r.start }
  end

  def each_rates
    CSV.foreach(File.dirname(__FILE__) + '/rate.csv') do |row|
      yield Rate.new(row[0].to_f, row[1].to_f, row[2].to_f, row[3].to_f)
    end
  end
end
