# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Rpc::Converters::TickConverter do
  class Converter

    include Jiji::Rpc::Converters

  end

  let(:converter) { Converter.new }

  describe '#convert_tick_to_pb' do
    it 'converts Tick to Rpc::Tick' do
      converted = converter.convert_tick_to_pb(Jiji::Model::Trading::Tick.new({
        EURJPY: Jiji::Model::Trading::Tick::Value.new(112.1, 112.34),
        USDJPY: Jiji::Model::Trading::Tick::Value.new(102.1, 102.34)
      }, Time.new(2017, 4, 15, 12, 34, 20)))
      expect(converted.timestamp.seconds).to eq 1_492_227_260
      expect(converted.timestamp.nanos).to be 0

      expect(converted.values.length).to be 2
      expect(converted.values[0].bid.value).to eq '112.1'
      expect(converted.values[0].ask.value).to eq '112.34'
      expect(converted.values[0].pair).to eq 'EURJPY'
      expect(converted.values[1].bid.value).to eq '102.1'
      expect(converted.values[1].ask.value).to eq '102.34'
      expect(converted.values[1].pair).to eq 'USDJPY'
    end
    it 'returns nil when a tick is nil' do
      converted = converter.convert_tick_to_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_tick_value_to_pb' do
    it 'converts Tick::Value to Rpc::Tick::Value' do
      converted = converter.convert_tick_value_to_pb(
        Jiji::Model::Trading::Tick::Value.new(112.1, 112.34), 'EURJPY')
      expect(converted.bid.value).to eq '112.1'
      expect(converted.ask.value).to eq '112.34'
      expect(converted.pair).to eq 'EURJPY'
    end
    it 'returns nil when a tick value is nil' do
      converted = converter.convert_tick_value_to_pb(nil, nil)
      expect(converted).to eq nil
    end
  end
end
