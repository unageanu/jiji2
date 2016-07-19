# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

describe Jiji::Model::Securities::Internal::Oanda::RateRetriever do
  let(:client) do
    Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  describe 'pairs' do
    it '通貨ペアの一覧を取得できる。' do
      pairs = client.retrieve_pairs
      # p pairs
      expect(pairs.length).to be > 0
      pairs.each do |pair|
        expect(pair.name).not_to be nil
        expect(pair.internal_id).not_to be nil
        expect(pair.pip).to be > 0
        expect(pair.max_trade_units).to be > 0
        expect(pair.precision).to be > 0
        expect(pair.margin_rate).to be > 0
      end
    end
  end

  describe 'retrieve_current_tick' do
    it '通貨ペアごとの現在価格を取得できる。' do
      tick = client.retrieve_current_tick
      # p tick
      expect(tick.length).to be > 0
      expect(tick.timestamp).not_to be nil
      expect(tick.timestamp.class).to be Time
      tick.each do |_k, v|
        expect(v.bid).to be > 0
        expect(v.ask).to be > 0
      end
    end
  end

  describe '#retrieve_tick_history' do
    it 'should return ticks for a currency pair.' do
      ticks = client.retrieve_tick_history(:EURJPY,
        Time.utc(2015, 5, 22, 12, 00, 00), Time.utc(2015, 5, 22, 12, 15, 00))
      # p ticks
      expect(ticks.length).to be 15 * 4
      time = Time.utc(2015, 5, 22, 12, 00, 00)
      ticks.each do |tick|
        expect(tick.timestamp).to eq time
        expect(tick.length).to be 1
        v = tick[:EURJPY]
        expect(v.bid).to be > 0
        expect(v.ask).to be > 0
        time = Time.at(time.to_i + 15).utc
      end
    end

    it 'should return ticks per hour.' do
      ticks = client.retrieve_tick_history(:EURJPY,
        Time.utc(2015, 5, 22, 12, 00, 00),
        Time.utc(2015, 5, 23, 12, 00, 00), :one_hour)
      # p ticks
      expect(ticks.length).to be 24
      time = Time.utc(2015, 5, 22, 12, 00, 00)
      ticks.each do |tick|
        expect(tick.timestamp).to eq time
        expect(tick.length).to be 1
        v = tick[:EURJPY]
        expect(v.bid).to be > 0
        expect(v.ask).to be > 0
        time = Time.at(time.to_i + 60 * 60).utc
      end
    end
  end

  describe 'retrieve_rate_history' do
    it '通貨ペアの4本値の履歴を取得できる。' do
      rates = client.retrieve_rate_history(:EURJPY, :one_hour,
        Time.utc(2015, 5, 21, 12, 00, 00), Time.utc(2015, 5, 22, 12, 00, 00))
      # p ticks
      expect(rates.length).to be 24
      time = Time.utc(2015, 5, 21, 12, 00, 00)
      rates.each do |rate|
        expect(rate.timestamp).to eq time
        expect(rate.open.bid).to be > 0
        expect(rate.open.ask).to be > 0
        expect(rate.close.bid).to be > 0
        expect(rate.close.ask).to be > 0
        expect(rate.high.bid).to be > 0
        expect(rate.high.ask).to be > 0
        expect(rate.low.bid).to be > 0
        expect(rate.low.ask).to be > 0
        time = Time.at(time.to_i + 60 * 60).utc
      end
    end

    context '週末などでレート情報がない場合、直近の情報で補完される' do
      it '途中のレートがない場合' do
        start_time = Time.utc(2015, 5, 1, 17)
        end_time   = Time.utc(2015, 5, 4, 6)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_hour, 61)

        start_time = Time.local(2015, 5, 1)
        end_time   = Time.local(2015, 5, 15)
        expect_to_enable_retrieve_rates(start_time, end_time, :six_hours, 56)

        start_time = Time.utc(2015, 5, 1)
        end_time   = Time.utc(2015, 5, 15)
        expect_to_enable_retrieve_rates(start_time, end_time, :six_hours, 56)

        start_time = Time.utc(2015, 4, 30, 10).localtime('+14:00')
        end_time   = Time.utc(2015, 5, 14, 10).localtime('+14:00')
        expect_to_enable_retrieve_rates(start_time, end_time, :six_hours, 56)

        start_time = Time.local(2015, 5, 1)
        end_time   = Time.local(2015, 5, 30)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_day, 29)

        start_time = Time.utc(2015, 5, 1)
        end_time   = Time.utc(2015, 5, 30)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_day, 29)
      end

      it '開始時点のレートがない場合' do
        start_time = Time.utc(2015, 5, 3, 17)
        end_time   = Time.utc(2015, 5, 6, 6)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_hour, 61)
      end

      it '終了時点のレートがない場合' do
        start_time = Time.utc(2015, 5, 1, 17)
        end_time   = Time.utc(2015, 5, 3, 6)
        expect_to_enable_retrieve_rates(start_time, end_time, :one_hour, 37)
      end
    end

    def expect_to_enable_retrieve_rates(start_time,
      end_time, interval_id, expected_rate_count)
      rates = client.retrieve_rate_history(
        :EURJPY, interval_id, start_time, end_time)

      interval = Jiji::Model::Trading::Intervals.instance.get(interval_id)
      expect(rates.length).to eq expected_rate_count
      time = interval.calcurate_interval_start_time(start_time)
      rates.each do |rate|
        check_rate(rate, time)
        time = Time.at(time.to_i + (interval.ms / 1000))
      end
    end

    def check_rate(rate, time)
      # puts "#{time} #{rate.timestamp} #{rate.open.bid} #{rate.close.bid}"
      expect(rate.timestamp).to eq time
      expect(rate.open.bid).to be > 0
      expect(rate.open.ask).to be > 0
      expect(rate.close.bid).to be > 0
      expect(rate.close.ask).to be > 0
      expect(rate.high.bid).to be > 0
      expect(rate.high.ask).to be > 0
      expect(rate.low.bid).to be > 0
      expect(rate.low.ask).to be > 0
    end
  end
end if ENV['OANDA_API_ACCESS_TOKEN']
