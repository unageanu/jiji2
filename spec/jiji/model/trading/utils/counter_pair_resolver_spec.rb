# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Utils::CounterPairResolver do
  include_context 'use data_builder'
  let(:pairs) do
    pairs = double('mock pairs')
    allow(pairs).to receive(:all).and_return([
      Jiji::Model::Trading::Pair.new(:EURUSD, 1, 0.01, 1, 1, 0.04),
      Jiji::Model::Trading::Pair.new(:USDJPY, 1, 0.01, 1, 1, 0.04),
      Jiji::Model::Trading::Pair.new(:EURJPY, 1, 0.01, 1, 1, 0.04),
      Jiji::Model::Trading::Pair.new(:EURDKK, 1, 0.01, 1, 1, 0.04)
    ])
    pairs
  end
  let(:tick) do
    Jiji::Model::Trading::Tick.new({
      EURUSD: data_builder.new_tick_value(1),
      USDJPY: data_builder.new_tick_value(2),
      EURJPY: data_builder.new_tick_value(3),
      EURDKK: data_builder.new_tick_value(4)
    }, Time.utc(2015, 5, 1, 0, 0, 0))
  end
  let(:resolver) do
    Jiji::Model::Trading::Utils::CounterPairResolver.new
  end

  describe '#resolve_rate' do
    it 'returns the mid rate' do
      expect(resolver.resolve_rate(tick, :EURUSD, 'JPY')).to eq 102.0015
      expect(resolver.resolve_rate(tick, :CADEUR, 'JPY')).to eq 103.0015
      expect(resolver.resolve_rate(tick, :CADEUR, 'USD')).to eq 101.0015

      expect(resolver.resolve_rate(tick, :EURJPY, 'JPY')).to eq 1
      expect(resolver.resolve_rate(tick, :CADEUR, 'EUR')).to eq 1
      expect(resolver.resolve_rate(tick, :EURUSD, 'USD')).to eq 1

      expect(resolver.resolve_rate(tick, :EURDKK, 'JPY')).to eq 0.990385
    end
  end

  describe '#resolve_pair' do
    it 'returns the counter pair.' do
      expect(resolver.resolve_pair(:EURUSD, 'JPY')).to eq :USDJPY
      expect(resolver.resolve_pair(:EURGBP, 'JPY')).to eq :GBPJPY
      expect(resolver.resolve_pair(:USDEUR, 'JPY')).to eq :EURJPY
      expect(resolver.resolve_pair(:USDJPY, 'JPY')).to eq :JPYJPY

      expect(resolver.resolve_pair(:EURUSD, 'USD')).to eq :USDUSD
      expect(resolver.resolve_pair(:EURGBP, 'USD')).to eq :GBPUSD
      expect(resolver.resolve_pair(:USDEUR, 'USD')).to eq :EURUSD
      expect(resolver.resolve_pair(:USDJPY, 'USD')).to eq :JPYUSD
    end
  end

  describe '#resolve_required_pairs' do
    it 'returns required pairs' do
      expect(resolver.resolve_required_pairs(pairs, :EURUSD, 'JPY'))
        .to eq [:USDJPY]
      expect(resolver.resolve_required_pairs(pairs, :CADEUR, 'JPY'))
        .to eq [:EURJPY]
      expect(resolver.resolve_required_pairs(pairs, :CADEUR, 'USD'))
        .to eq [:EURUSD]

      expect(resolver.resolve_required_pairs(pairs, :EURJPY, 'JPY')).to eq []
      expect(resolver.resolve_required_pairs(pairs, :CADEUR, 'EUR')).to eq []
      expect(resolver.resolve_required_pairs(pairs, :EURUSD, 'USD')).to eq []

      expect(resolver.resolve_required_pairs(pairs, :EURDKK, 'JPY'))
        .to eq %i[EURJPY EURDKK]
    end

    it 'can resolve in all available currency pairs.' do
      all_pairs = double('mock pairs')
      pair_names = %w[
        USDJPY EURJPY AUDJPY GBPJPY NZDJPY CADJPY
        CHFJPY ZARJPY EURUSD GBPUSD NZDUSD AUDUSD
        USDCHF EURCHF GBPCHF EURGBP AUDNZD AUDCAD
        AUDCHF CADCHF EURAUD EURCAD EURDKK EURNOK
        EURNZD EURSEK GBPAUD GBPCAD GBPNZD NZDCAD
        NZDCHF USDCAD USDDKK USDNOK USDSEK AUDHKD
        AUDSGD CADHKD CADSGD CHFHKD CHFZAR EURCZK
        EURHKD EURHUF EURPLN EURSGD EURTRY EURZAR
        GBPHKD GBPPLN GBPSGD GBPZAR HKDJPY NZDHKD
        NZDSGD SGDCHF SGDHKD SGDJPY TRYJPY USDCNH
        USDCZK USDHKD USDHUF USDINR USDMXN USDPLN
        USDSAR USDSGD USDTHB USDTRY USDZAR
      ]
      allow(all_pairs).to receive(:all).and_return(pair_names.map do |name|
        Jiji::Model::Trading::Pair.new(name.to_sym, 1, 0.01, 1, 1, 0.04)
      end)
      all_pairs.all.each do |pair|
        expect(resolver.resolve_required_pairs(all_pairs, pair.name, 'JPY'))
          .not_to eq nil
      end
    end
  end
end
