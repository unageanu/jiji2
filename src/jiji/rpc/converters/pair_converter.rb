# coding: utf-8

require 'grpc'

module Jiji::Rpc::Converters
  module PairConverter
    include Jiji::Rpc

    def convert_pairs_to_pb(pairs)
      return nil unless pairs
      pairs.map do |pair|
        convert_pair_to_pb(pair)
      end
    end

    def convert_pair_to_pb(pair)
      return nil unless pair
      Pair.new(convert_hash_values_to_pb(pair.to_h))
    end
  end
end
