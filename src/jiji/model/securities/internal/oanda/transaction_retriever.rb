# frozen_string_literal: true

require 'jiji/model/securities/internal/utils/converter'

module Jiji::Model::Securities::Internal::Oanda
  module TransactionRetriever
    include Jiji::Errors
    include Jiji::Model::Securities::Internal::Utils

    def retrieve_transactions(count = 500,
      pair_name = nil, min_id = nil, max_id = nil)
      param = { count: count }
      if pair_name
        param[:instrument] =
          Converter.convert_pair_name_to_instrument(pair_name)
      end
      if max_id.nil? || min_id.nil?
        max_id = @client.account(@account['id']).transactions(param).show['lastTransactionID']
        min_id = (max_id.to_i - count + 1).to_s
      end
      param[:to] = max_id if max_id
      param[:from] = min_id if min_id
      @client.account(@account['id']).transactions_id_range(param).show['transactions']
    end
  end
end
