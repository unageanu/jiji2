# coding: utf-8

require 'grpc'

module Jiji::Rpc::Converters
  module AccountConverter
    include Jiji::Rpc

    def convert_account_to_pb(account)
      return nil unless account
      hash = account.to_h
      convert_numeric_to_pb_decimal(hash, [
        :balance,
        :profit_or_loss,
        :margin_used,
        :margin_rate
      ])
      Account.new(convert_hash_values_to_pb(hash))
    end
  end
end
