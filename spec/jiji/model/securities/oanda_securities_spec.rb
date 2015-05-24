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

  # describe 'get_current_ticks' do
  #   it '通貨ペアごとの現在価格を取得できる。' do
  #     ticks = @client.current_ticks
  #     # p ticks
  #     expect(ticks.length).to be > 0
  #     ticks.each do |tick|
  #       expect(tick.instrument).not_to be nil
  #       expect(tick.time).not_to be nil
  #       expect(tick.bid).to be > 0
  #       expect(tick.ask).to be > 0
  #     end
  #   end
  # end
end
