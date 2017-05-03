# coding: utf-8

require 'grpc'

module Jiji::Rpc::Converters
  module AccountConverter
    include Jiji::Rpc

    def convert_account_to_pb(account)
      return nil unless account
      Account.new(convert_hash_values_to_pb(account.to_h))
    end

  end
end
