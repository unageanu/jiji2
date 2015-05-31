# coding: utf-8

require 'oanda_api'
require 'jiji/model/securities/internal/converter'

module Jiji::Model::Securities
  OandaAPI.configure do |config|
    config.use_compression = true
    config.use_request_throttling = true
  end

  class OandaSecurities

    include Jiji::Errors
    include Jiji::Model::Trading
    include Internal::Ordering
    include Internal::RateRetriever

    def self.configuration_definition
      [{ id: :access_token, description: 'アクセストークン' }]
    end

    def initialize(config)
      @client  = create_client(config[:access_token])
      @account = find_account(config[:account_name] || 'Primary')
    end

    def destroy
    end

    def commit(_position_id, count)
    end

    def find_account(account_name)
      accounts = @client.accounts.get
      accounts.find { |a| a.account_name == account_name } \
        || not_found(OandaAPI::Resource::Account, account_name: account_name)
    end

    private

    def create_client(token)
      @client  = OandaAPI::Client::TokenClient.new(:live, token)
    end

  end

  class OandaDemoSecurities < OandaSecurities

    def create_client(token)
      @client  = OandaAPI::Client::TokenClient.new(:practice, token)
    end

  end
end
