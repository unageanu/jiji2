# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Utils::PricingUtils do
  include_context 'use data_builder'

  let(:tick) do
    Jiji::Model::Trading::Tick.new({
      EURUSD: data_builder.new_tick_value(1),
      USDJPY: data_builder.new_tick_value(2),
      EURJPY: data_builder.new_tick_value(3)
    }, Time.utc(2015, 5, 1, 0, 0, 0))
  end
  let(:utils) do
    Jiji::Model::Trading::Utils::PricingUtils
  end

  describe '#calculate_entry_price' do
    it 'returns the ask rate if sell_or_buy == :buy' do
      expect(utils.calculate_entry_price(tick, :USDJPY, :buy)).to eq 102.003
      expect(utils.calculate_entry_price(tick, :EURUSD, :buy)).to eq 101.003
    end
    it 'returns the bid rate if sell_or_buy == :sell' do
      expect(utils.calculate_entry_price(tick, :USDJPY, :sell)).to eq 102
      expect(utils.calculate_entry_price(tick, :EURUSD, :sell)).to eq 101
    end
  end

  describe '#calculate_current_price' do
    it 'returns the bid rate if sell_or_buy == :buy' do
      expect(utils.calculate_current_price(tick, :USDJPY, :buy)).to eq 102
      expect(utils.calculate_current_price(tick, :EURUSD, :buy)).to eq 101
    end
    it 'returns the ask rate if sell_or_buy == :sell' do
      expect(utils.calculate_current_price(tick, :USDJPY, :sell)).to eq 102.003
      expect(utils.calculate_current_price(tick, :EURUSD, :sell)).to eq 101.003
    end
  end

  describe '#calculate_current_counter_rate' do
    it 'returns the mid rate' do
      expect(utils.calculate_current_counter_rate(tick, :EURUSD, 'JPY'))
        .to eq 102.0015
      expect(utils.calculate_current_counter_rate(tick, :CADEUR, 'JPY'))
        .to eq 103.0015
      expect(utils.calculate_current_counter_rate(tick, :CADEUR, 'USD'))
        .to eq 101.0015
      expect(utils.calculate_current_counter_rate(tick, :EURJPY, 'JPY'))
        .to eq 1
      expect(utils.calculate_current_counter_rate(tick, :CADEUR, 'EUR'))
        .to eq 1
      expect(utils.calculate_current_counter_rate(tick, :EURUSD, 'USD'))
        .to eq 1
    end
  end

  describe '#counter_pair_for' do
    it 'returns the counter pair.' do
      expect(utils.resolve_counter_pair_for(:EURUSD, 'JPY')).to eq :USDJPY
      expect(utils.resolve_counter_pair_for(:EURGBP, 'JPY')).to eq :GBPJPY
      expect(utils.resolve_counter_pair_for(:USDEUR, 'JPY')).to eq :EURJPY
      expect(utils.resolve_counter_pair_for(:USDJPY, 'JPY')).to eq :JPYJPY

      expect(utils.resolve_counter_pair_for(:EURUSD, 'USD')).to eq :USDUSD
      expect(utils.resolve_counter_pair_for(:EURGBP, 'USD')).to eq :GBPUSD
      expect(utils.resolve_counter_pair_for(:USDEUR, 'USD')).to eq :EURUSD
      expect(utils.resolve_counter_pair_for(:USDJPY, 'USD')).to eq :JPYUSD
    end
  end
end
