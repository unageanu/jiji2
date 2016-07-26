# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'
require 'jiji/model/securities/internal/examples/rate_retriever_examples'

describe Jiji::Model::Securities::Internal::Oanda::RateRetriever do
  let(:client) do
    Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  it_behaves_like 'rate_retriever'

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
        Time.utc(2015, 5, 22, 12, 0o0, 0o0), Time.utc(2015, 5, 22, 12, 15, 0o0))
      # p ticks
      expect(ticks.length).to be 15 * 4
      time = Time.utc(2015, 5, 22, 12, 0o0, 0o0)
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
        Time.utc(2015, 5, 22, 12, 0o0, 0o0),
        Time.utc(2015, 5, 23, 12, 0o0, 0o0), :one_hour)
      # p ticks
      expect(ticks.length).to be 24
      time = Time.utc(2015, 5, 22, 12, 0o0, 0o0)
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
end if ENV['OANDA_API_ACCESS_TOKEN']
