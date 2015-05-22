# coding: utf-8

require 'oanda_api'

module Jiji::Model::Securities
  OandaAPI.configure do |config|
    config.use_compression = true
    config.use_request_throttling = true
  end

  class OandaSecuritiesClient

    include Jiji::Errors

    def initialize(env, token, account_name = 'Primary')
      @client  = OandaAPI::Client::TokenClient.new(env, token)
      @account = find_account(account_name)
    end

    def destroy
    end

    def pairs
      @client.instruments(account_id: @account.account_id).get
    end

    def current_ticks
      @client.prices(instruments: retrive_all_pairs).get
    end

    def order(_pair, sell_or_buy, count)
    end

    def commit(_position_id, count)
    end

    def find_account(account_name)
      accounts = @client.accounts.get
      accounts.find { |a| a.account_name == account_name } \
        || not_found(OandaAPI::Resource::Account, account_name: account_name)
    end

    private

    def retrive_all_pairs
      @all_pairs ||= pairs.map { |v| v.instrument }
    end

  end
end
