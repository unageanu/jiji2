# frozen_string_literal: true

require 'oanda_api_v20'
require 'jiji/model/securities/internal/utils/converter'
require 'jiji/model/securities/internal/oanda/ordering'
require 'jiji/model/securities/internal/oanda/rate_retriever'
require 'jiji/model/securities/internal/oanda/trading'
require 'jiji/model/securities/internal/oanda/transaction_retriever'

module Jiji::Model::Securities
  class OandaSecurities

    include Jiji::Errors
    include Jiji::Model::Trading

    include Internal::Oanda::RateRetriever
    include Internal::Oanda::Ordering
    include Internal::Oanda::Trading
    include Internal::Oanda::TransactionRetriever
    include Internal::Oanda::CalendarRetriever

    include Jiji::Model::Securities::Internal::Utils

    def self.configuration_definition
      [{ id: :access_token, description: 'アクセストークン' }]
    end

    def initialize(config)
      @client  = create_client(config[:access_token])
      @account = find_account(config[:account_name] || 'Primary')
      @position_builder = Jiji::Model::Trading::Internal::PositionBuilder.new
      @order_validator = OrderValidator.new
    end

    def destroy; end

    def retrieve_account
      response = @client.account(@account['id']).show['account']
      Account.new(response['id'], response['currency'],
        BigDecimal(response['balance'], 10), BigDecimal(response['marginRate'], 10)) do |a|
        a.profit_or_loss = BigDecimal(response['unrealizedPL'], 10)
        a.margin_used    = BigDecimal(response['marginUsed'], 10)
      end
    end

    def account_currency
      @account_currency ||=
        @client.account(@account['id']).show['account']['currency']
    end

    def find_account(account_name)
      accounts = @client.accounts.show
      accounts['accounts']
        .map { |a| @client.account(a['id']).summary.show['account'] }
        .find { |a| a['alias'] == account_name } \
        || not_found(Account, account_name: account_name)
    end

    private

    def create_client(token)
      @client  = OandaApiV20.new(access_token: token)
    end

  end

  class OandaDemoSecurities < OandaSecurities

    def create_client(token)
      @client  = OandaApiV20.new(access_token: token, practice: true)
    end

  end
end
