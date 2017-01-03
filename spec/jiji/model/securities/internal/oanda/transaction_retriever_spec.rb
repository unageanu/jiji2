# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

if ENV['OANDA_API_ACCESS_TOKEN']
  describe Jiji::Model::Securities::Internal::Oanda::RateRetriever do
    before(:example) do
      @client = Jiji::Model::Securities::OandaDemoSecurities.new(
        access_token: ENV['OANDA_API_ACCESS_TOKEN'])
    end

    after(:example) do
    end

    it 'トランザクションの一覧を取得できる。' do
      transactions = @client.retrieve_transactions(10)
      expect(transactions.length).to be 10
      transactions.each do |t|
        expect(t.id).not_to be nil
        expect(t.type).not_to be nil
        expect(t.time).not_to be nil
      end
    end
  end
end
