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

  describe 'retrieve_account' do
    it '名前に対応するアカウントを取得できる。' do
      account = @client.retrieve_account
      expect(account.account_id).to be > 0
      expect(account.margin_rate).not_to be nil
      expect(account.balance).to be >= 0
      expect(account.margin_used).to be >= 0
      expect(account.profit_or_loss).not_to be nil
    end
  end

  describe '#account_currency' do
    it 'returns the currency of the account.' do
      expect(@client.account_currency).to eq 'JPY'
    end
  end

end if ENV['OANDA_API_ACCESS_TOKEN']
