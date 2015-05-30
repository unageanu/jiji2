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
    include Internal::Converter

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
        fields:     %w(displayName pip maxTradeUnits precision marginRate)
      }).get.map { |item| convert_response_to_pair(item) }
    end

    def retrieve_current_tick
      prices = @client.prices(instruments: retrieve_all_pairs).get
      convert_response_to_tick(prices)
    end

    def retrieve_tick_history(pair_name, start_time, end_time)
      retrieve_candles(pair_name,
        'S15', start_time, end_time).get.map do |item|
        values = {}
        values[pair_name] = Tick::Value.new(
          item.open_bid.to_f, item.open_ask.to_f)
        Tick.new(values, item.time)
      end
    end

    def retrieve_rate_history(pair_name, interval, start_time, end_time)
      granularity =
        Internal::Converter.convert_interval_to_granularity(interval)
      retrieve_candles(pair_name,
        granularity, start_time, end_time).get.map do |item|
        convert_response_to_rate(pair_name, item)
      end
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

    def retrieve_candles(pair_name, interval,
      start_time, end_time, candle_format = 'bidask')
      @client.candles({
        instrument:    Internal::Converter
          .convert_pair_name_to_instrument(pair_name),
        granularity:   interval,
        candle_format: candle_format,
        start:         start_time.utc.to_datetime.rfc3339,
        end:           end_time.utc.to_datetime.rfc3339
      })
    end

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
