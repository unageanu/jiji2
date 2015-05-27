# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

describe Jiji::Model::Securities::OandaSecurities do
  before(:example) do
    @client = Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  after(:example) do
  end

  it '不正なトークンを指定した場合、エラー' do
    expect do
      Jiji::Model::Securities::OandaDemoSecurities.new(
        access_token: 'illegal_token')
    end.to raise_exception(OandaAPI::RequestError)
  end

  describe 'find_account' do
    it '名前に対応するアカウントを取得できる。' do
      account = @client.find_account('Primary')
      # p account
      expect(account.account_name).to eq 'Primary'
      expect(account.account_id).to be > 0
      expect(account.account_currency).to eq 'JPY'
      expect(account.margin_rate).not_to be nil
    end

    it '名前に対応するアカウントが見つからない場合、エラー' do
      expect do
        @client.find_account('not_found')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe 'pairs' do
    it '通貨ペアの一覧を取得できる。' do
      pairs = @client.retrieve_pairs
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
      tick = @client.retrieve_current_tick
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

  describe 'retrieve_tick_history' do
    it '通貨ペアの価格履歴を取得できる。' do
      ticks = @client.retrieve_tick_history(:EURJPY,
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
  end

  describe 'retrieve_rate_history' do
    it '通貨ペアの4本値の履歴を取得できる。' do
      rates = @client.retrieve_rate_history(:EURJPY, :one_hour,
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
  end
end
