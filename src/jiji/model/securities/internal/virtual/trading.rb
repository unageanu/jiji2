# coding: utf-8

require 'oanda_api'
require 'jiji/model/securities/internal/oanda/converter'

module Jiji::Model::Securities::Internal::Virtual
  module Trading
    include Jiji::Errors
    include Jiji::Model::Trading

    def init_trading_state
      @positions = []
    end

    def retrieve_trades(count = 500, pair_name = nil, max_id = nil)
      @positions.map { |o| o.clone }
    end

    def retrieve_trade_by_id(internal_id)
      find_position_by_internal_id(internal_id).clone
    end

    def modify_trade(internal_id, options = {})
      position = find_position_by_internal_id(internal_id)
      policy = position.closing_policy
      [:take_profit, :stop_loss, :trailing_stop].each do |key|
        policy.method("#{key}=").call(options[key]) if options.include?(key)
      end
      position.clone
    end

    def close_trade(internal_id)
      position = find_position_by_internal_id(internal_id)
      @positions = @positions.reject { |o| o.internal_id == internal_id }
      convert_to_closed_position(position)
    end

    private

    def find_position_by_internal_id(internal_id)
      @positions.find { |o| o.internal_id == internal_id } \
      || error('order not found')
    end
  end
end
