# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities_client'

describe Jiji::Model::Securities::OandaSecuritiesClient do
  before(:example) do
    @client = Jiji::Model::Securities::OandaSecuritiesClient.new(
      :practice, ENV['OANDA_API_ACCESS_TOKEN'])
  end

  after(:example) do
  end

  it '不正なトークンを指定した場合、エラー' do
    expect do
      Jiji::Model::Securities::OandaSecuritiesClient.new(
        :practice, 'illegal_token')
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

  describe 'get_pairs' do
    it '通貨ペアの一覧を取得できる。' do
      pairs = @client.get_pairs
      # p pairs
      expect(pairs.length).to be > 0
      pairs.each do |pair|
        expect(pair.instrument).not_to be nil
        expect(pair.display_name).not_to be nil
        expect(pair.pip).not_to be nil
        expect(pair.max_trade_units).to be > 0
      end
    end
  end

  describe 'get_current_ticks' do
    it '通貨ペアごとの現在価格を取得できる。' do
      ticks = @client.get_current_ticks
      # p ticks
      expect(ticks.length).to be > 0
      ticks.each do |tick|
        expect(tick.instrument).not_to be nil
        expect(tick.time).not_to be nil
        expect(tick.bid).to be > 0
        expect(tick.ask).to be > 0
      end
    end
  end
end
