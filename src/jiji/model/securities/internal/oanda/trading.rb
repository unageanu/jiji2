# coding: utf-8

require 'oanda_api'
require 'jiji/model/securities/internal/oanda/converter'

module Jiji::Model::Securities::Internal::Oanda
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
      convert_response_to_position(response)
    end

    def close_trade(internal_id)
      response = @client.account(@account.account_id)
        .trade(internal_id).close
      ClosedPosition.new(internal_id, -1, response.price,
        response.time, response.profit)
    end

    private

    def convert_response_to_position(trade)
      @position_builder.build_from_trade(trade)
    end
  end
end
