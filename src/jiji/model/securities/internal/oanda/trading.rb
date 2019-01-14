# frozen_string_literal: true

require 'jiji/model/securities/internal/utils/converter'

module Jiji::Model::Securities::Internal::Oanda
  module Trading
    include Jiji::Errors
    include Jiji::Model::Trading
    include Jiji::Model::Securities::Internal::Utils

    def retrieve_trades(count = 500, pair_name = nil, max_id = nil)
      param = { count: count }
      if pair_name
        param[:instrument] =
          Converter.convert_pair_name_to_instrument(pair_name)
      end
      param[:max_id] = max_id if max_id
      tick = retrieve_current_tick
      @client.account(@account["id"])
        .trades(param).show["trades"].map do |item|
        convert_response_to_position(item, tick)
      end
    end

    def retrieve_trade_by_id(internal_id)
      tick = retrieve_current_tick
      response = @client.account(@account["id"])
        .trade(internal_id).show["trade"]
      convert_response_to_position(response, tick)
    end

    def modify_trade(internal_id, options = {})
      options = Converter.convert_option_to_oanda(options)
      @client.account(@account["id"])
        .trade(internal_id, options).update
      retrieve_trade_by_id(internal_id)
    end

    def close_trade(internal_id)
      response = @client.account(@account["id"])
        .trade(internal_id).close["orderFillTransaction"]
      ClosedPosition.new(internal_id, -1, BigDecimal(response["price"], 10),
        Time.parse(response["time"]), BigDecimal(response["pl"], 10))
    end

    private

    def convert_response_to_position(trade, tick)
      position = @position_builder.build_from_trade(trade)
      position.update_price(tick, account_currency)
      position
    end
  end
end
