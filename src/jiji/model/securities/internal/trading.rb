# coding: utf-8

require 'oanda_api'
require 'jiji/model/securities/internal/converter'

module Jiji::Model::Securities::Internal
  module Trading
    include Jiji::Errors
    include Jiji::Model::Trading

    def retrieve_trades(count = 500, pair_name = nil, max_id = nil)
      param = { count: count }
      if pair_name
        param[:instrument] =
          Converter.convert_pair_name_to_instrument(pair_name)
      end
      param[:max_id] = max_id if max_id
      @client.account(@account.account_id)
        .trades(param).get.map do |item|
        convert_response_to_position(item)
      end
    end

    def retrieve_trade_by_id(internal_id)
      response = @client.account(@account.account_id)
                 .trade(internal_id).get
      convert_response_to_position(response)
    end

    def modify_trade(internal_id, options = {})
      response = @client.account(@account.account_id)
                 .trade({ id: internal_id }.merge(options)).update
      convert_response_to_trade(response, response)
    end

    def close_trade(internal_id)
      @client.account(@account.account_id)
        .trade(internal_id).close
    end

    private

    def convert_response_to_position(item)
      pair_name = Converter.convert_instrument_to_pair_name(item.instrument)
      Position.new do |p|
        p.initialize_trading_information(nil, item.id,
          pair_name, item.units, item.side.to_sym)
        initialize_price_information(p, item)
        p.closing_policy = ClosingPolicy.create(extract_options(item))
      end
    end

    def initialize_price_information(p, item)
      p.entry_price = item.price.to_f
      p.entered_at  = item.time
    end

    def extract_options(item)
      {
        stop_loss:       item.stop_loss,
        take_profit:     item.take_profit,
        trailing_stop:   item.trailing_stop,
        trailing_amount: item.trailing_amount
      }
    end
  end
end
