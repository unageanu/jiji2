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
      granularity = OandaSecurities.convert_interval_to_granularity(interval)
      retrieve_candles(pair_name,
        granularity, start_time, end_time).get.map do |item|
        Rate.new(pair_name, item.time,
          Tick::Value.new(item.open_bid.to_f, item.open_ask.to_f),
          Tick::Value.new(item.close_bid.to_f, item.close_ask.to_f),
          Tick::Value.new(item.high_bid.to_f, item.high_ask.to_f),
          Tick::Value.new(item.low_bid.to_f, item.low_ask.to_f))
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
        instrument:    OandaSecurities
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

    def convert_response_to_pair(item)
      Pair.new(
        OandaSecurities.convert_instrument_to_pair_name(item.instrument),
        item.instrument, item.pip.to_f, item.max_trade_units.to_i,
        item.precision.to_f, item.margin_rate.to_f)
    end

    def convert_response_to_tick(prices)
      timestamp = nil
      values = prices.each_with_object({}) do |p, r|
        timestamp ||= p.time
        pair_name = OandaSecurities.convert_instrument_to_pair_name(
          p.instrument)
        r[pair_name] = Tick::Value.new(p.ask.to_f, p.bid.to_f)
      end
      Tick.new(values, timestamp)
    end

    def self.convert_instrument_to_pair_name(instrument)
      instrument.gsub(/\_/, '').to_sym
    end
    def self.convert_pair_name_to_instrument(pair_name)
      "#{pair_name.to_s[0..2]}_#{pair_name.to_s[3..-1]}"
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def self.convert_interval_to_granularity(interval)
      case interval
      when :one_minute      then 'M1'
      when :fifteen_minutes then 'M15'
      when :thirty_minutes  then 'M30'
      when :one_hour        then 'H1'
      when :six_hours       then 'H6'
      when :one_day         then 'D'
      else not_found('interval', interval: interval)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

  end

  class OandaDemoSecurities < OandaSecurities

    def create_client(token)
      @client  = OandaAPI::Client::TokenClient.new(:practice, token)
    end

  end
end
