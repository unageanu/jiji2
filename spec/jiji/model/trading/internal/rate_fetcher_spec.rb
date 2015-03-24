# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::RateFetcher do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @fetcher = Jiji::Model::Trading::Internal::RateFetcher.new
  end

  after(:example) do
    @data_builder.clean
  end

  it 'fetch でレート一覧を取得できる' do
    @data_builder.register_ticks(1001)

    [:EURJPY, :USDJPY, :EURUSD].each do |pair_id|
      rates = @fetcher.fetch(pair_id, Time.at(12 * 20), Time.at(72 * 20))

      expect(rates.length).to eq(20)
      expect(rates[0].timestamp).to eq(Time.at(4 * 60))
      expect(rates[0].open.values).to eq([102.0, 102.003, 4, 22])
      expect(rates[0].low.values).to eq([102.0, 102.003, 4, 22])
      expect(rates[0].high.values).to eq([104.0, 104.003, 6, 24])
      expect(rates[0].close.values).to eq([104.0, 104.003, 6, 24])

      expect(rates[9].timestamp).to eq(Time.at(13 * 60))
      expect(rates[9].open.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[9].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[9].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[9].close.values).to eq([101.0, 101.003,  3, 21])

      expect(rates[19].timestamp).to eq(Time.at(23 * 60))
      expect(rates[19].open.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[19].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[19].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[19].close.values).to eq([101.0, 101.003,  3, 21])

      rates = @fetcher.fetch(pair_id, Time.at(990 * 20), Time.at(1200 * 20))

      expect(rates.length).to eq(4)
      expect(rates[0].timestamp).to eq(Time.at(330 * 60))
      expect(rates[0].open.values).to eq([100.0, 100.003, 2, 20])
      expect(rates[0].low.values).to eq([100.0, 100.003, 2, 20])
      expect(rates[0].high.values).to eq([102.0, 102.003, 4, 22])
      expect(rates[0].close.values).to eq([102.0, 102.003, 4, 22])

      expect(rates[3].timestamp).to eq(Time.at(333 * 60))
      expect(rates[3].open.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[3].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[3].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[3].close.values).to eq([100.0, 100.003,  2, 20])

      rates = @fetcher.fetch(pair_id,
        Time.at(0 * 20), Time.at(300 * 20), :fifteen_minutes)

      expect(rates.length).to eq(7)
      expect(rates[0].timestamp).to eq(Time.at(0 * 60))
      expect(rates[0].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[0].close.values).to eq([104.0, 104.003,  6, 24])

      expect(rates[6].timestamp).to eq(Time.at(6 * 60 * 15))
      expect(rates[6].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[6].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[6].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[6].close.values).to eq([109.0, 109.003, 11, 29])

      rates = @fetcher.fetch(pair_id,
        Time.at(0 * 20), Time.at(600 * 20), :thirty_minutes)

      expect(rates.length).to eq(7)
      expect(rates[0].timestamp).to eq(Time.at(0 * 60))
      expect(rates[0].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[0].close.values).to eq([109.0, 109.003, 11, 29])

      expect(rates[6].timestamp).to eq(Time.at(6 * 60 * 30))
      expect(rates[6].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[6].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[6].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[6].close.values).to eq([109.0, 109.003, 11, 29])

      rates = @fetcher.fetch(pair_id,
        Time.at(0 * 20), Time.at(600 * 20), :one_hour)

      expect(rates.length).to eq(4)
      expect(rates[0].timestamp).to eq(Time.at(0 * 60))
      expect(rates[0].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[0].close.values).to eq([109.0, 109.003, 11, 29])

      expect(rates[3].timestamp).to eq(Time.at(3 * 60 * 60))
      expect(rates[3].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[3].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[3].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[3].close.values).to eq([109.0, 109.003, 11, 29])

      rates = @fetcher.fetch(pair_id,
        Time.at(0 * 20), Time.at(1200 * 20), :six_hours)

      expect(rates.length).to eq(1)
      expect(rates[0].timestamp).to eq(Time.at(0 * 60))
      expect(rates[0].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[0].close.values).to eq([100.0, 100.003,  2, 20])

      rates = @fetcher.fetch(pair_id,
        Time.at(0 * 20), Time.at(1200 * 20), :one_day)

      expect(rates.length).to eq(1)
      expect(rates[0].timestamp).to eq(Time.at(0 * 60))
      expect(rates[0].open.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].low.values).to eq([100.0, 100.003,  2, 20])
      expect(rates[0].high.values).to eq([109.0, 109.003, 11, 29])
      expect(rates[0].close.values).to eq([100.0, 100.003,  2, 20])
    end
  end

  it 'rangeで返された範囲のレート一覧を取得できる' do
    t = @data_builder.new_tick(1, Time.now)
    t.save

    swap = Jiji::Model::Trading::Internal::Swap.new do |s|
      s.pair_id   = Jiji::Model::Trading::Pairs
      .instance.create_or_get(:EURJPY).pair_id
      s.buy_swap  = 10
      s.sell_swap = -20
      s.timestamp = t.timestamp
    end
    swap.save

    range = Jiji::Model::Trading::TickRepository.new.range
    rates = @fetcher.fetch(:EURJPY,
      Time.parse(range[:start].iso8601),
      Time.parse((range[:end] + 1).iso8601))

    expect(rates.length).to eq(1)
  end

  it '不明なinterval,pairが指定された場合、エラーになる' do
    @data_builder.register_ticks(1)

    expect do
      @fetcher.fetch(:UNKNOWN_PAIR,
        Time.at(0), Time.at(10 * 20), :fifteen_minutes)
    end.to raise_exception(Jiji::Errors::NotFoundException)

    expect do
      @fetcher.fetch(:EURJPY,
        Time.at(0), Time.at(10 * 20), :unknown_interval)
    end.to raise_exception(Jiji::Errors::NotFoundException)
  end
end
