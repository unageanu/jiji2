# coding: utf-8

require 'oanda_api'

module Jiji::Model::Securities
  OandaAPI.configure do |config|
    config.use_compression = true
    config.use_request_throttling = true
  end

  class OandaSecurities

    include Jiji::Errors
    include Jiji::Model::Trading

    def self.configuration_definition
      [{ id: :access_token, description: 'アクセストークン' }]
    end

    def initialize(config)
      @client  = create_client(config[:access_token])
      @account = find_account(config[:account_name] || 'Primary')
    end

    def destroy
    end

    def retrieve_pairs
      @client.instruments({
        account_id: @account.account_id,
        fields: [
          "displayName", "pip", "maxTradeUnits",
          "precision", "marginRate"
        ]
      }).get.map do|item|
        Pair.new(convert_pair_name(item.instrument),
          item.instrument, item.pip.to_f, item.max_trade_units.to_i,
          item.precision.to_f, item.margin_rate.to_f )
      end
    end

    def retrieve_current_ticks
      @client.prices(instruments: retrieve_all_pairs).get
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

    def retrieve_all_pairs
      @all_pairs ||= retrieve_pairs.map { |v| v.internal_id }
    end

    def create_client(token)
      @client  = OandaAPI::Client::TokenClient.new(:live, token)
    end

    def convert_pair_name(instrument)
      instrument.gsub(/\_/, '').to_sym
    end

  end

  class OandaDemoSecurities < OandaSecurities

    def create_client(token)
      @client  = OandaAPI::Client::TokenClient.new(:practice, token)
    end

  end
end
