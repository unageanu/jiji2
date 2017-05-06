# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Rpc::Converters::PairConverter do
  class Converter

    include Jiji::Rpc::Converters

  end

  let(:converter) { Converter.new }

  describe '#convert_pair_to_pb' do
    it 'converts Pair to Rpc::Pair' do
      Pair = Jiji::Model::Trading::Pair
      converted = converter.convert_pair_to_pb(
        Pair.new(:EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04))
      expect(converted.name).to eq 'EURJPY'
      expect(converted.internal_id).to eq 'EUR_JPY'
      expect(converted.pip.value).to eq '0.01'
      expect(converted.max_trade_units).to eq 10_000_000
      expect(converted.precision.value).to eq '0.001'
      expect(converted.margin_rate.value).to eq '0.04'
    end
    it 'returns nil when a pair is nil' do
      converted = converter.convert_pair_to_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_pairs_to_pb' do
    it 'converts Pairs to Rpc::Pairs' do
      Pair = Jiji::Model::Trading::Pair
      converted = converter.convert_pairs_to_pb([
        Pair.new(:EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
        Pair.new(:EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04),
        Pair.new(:USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
      ])
      expect(converted.length).to eq 3

      converted = converter.convert_pairs_to_pb([])
      expect(converted.length).to eq 0
    end
    it 'returns nil when an array of pair is nil' do
      converted = converter.convert_pairs_to_pb(nil)
      expect(converted).to eq nil
    end
  end
end
