# frozen_string_literal: true

require 'jiji/model/securities/internal/oanda/converter'

module Jiji::Model::Securities::Internal::Oanda
  module TransactionRetriever
    include Jiji::Errors

    def retrieve_transactions(count = 500,
      pair_name = nil, min_id = nil, max_id = nil)
      param = { count: count }
      if pair_name
        param[:instrument] =
          Converter.convert_pair_name_to_instrument(pair_name)
      end
      param[:max_id] = max_id if max_id
      param[:min_id] = min_id if min_id
      @client.account(@account["id"]).transactions(param).get
    end
  end
end
