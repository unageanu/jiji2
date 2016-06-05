# coding: utf-8

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
  let(:pricing_utils) do
    Jiji::Model::Trading::Utils::PricingUtils
  end

  describe 'calculate_entry_price' do
    it 'returns the ask rate if sell_or_buy == :buy' do
      expect(pricing_utils.calculate_entry_price(tick, :USDJPY, :buy))
        .to eq 102.003
      expect(pricing_utils.calculate_entry_price(tick, :EURUSD, :buy))
        .to eq 101.003
    end
    it 'returns the bid rate if sell_or_buy == :sell' do
      expect(pricing_utils.calculate_entry_price(tick, :USDJPY, :sell))
        .to eq 102
      expect(pricing_utils.calculate_entry_price(tick, :EURUSD, :sell))
        .to eq 101
    end
  end

  describe 'calculate_current_price' do
    it 'returns the bid rate if sell_or_buy == :buy' do
      expect(pricing_utils.calculate_current_price(tick, :USDJPY, :buy))
        .to eq 102
      expect(pricing_utils.calculate_current_price(tick, :EURUSD, :buy))
        .to eq 101
    end
    it 'returns the ask rate if sell_or_buy == :sell' do
      expect(pricing_utils.calculate_current_price(tick, :USDJPY, :sell))
        .to eq 102.003
      expect(pricing_utils.calculate_current_price(tick, :EURUSD, :sell))
        .to eq 101.003
    end
  end

  describe 'calculate_current_counter_rate' do
    it 'returns the mid rate' do
      expect(pricing_utils.calculate_current_counter_rate(tick, :USDJPY))
        .to eq 102.0015
      expect(pricing_utils.calculate_current_counter_rate(tick, :EURJPY))
        .to eq 103.0015
      expect(pricing_utils.calculate_current_counter_rate(tick, :EURUSD))
        .to eq 101.0015
      expect(pricing_utils.calculate_current_counter_rate(tick, :JPYJPY))
        .to eq 1
      expect(pricing_utils.calculate_current_counter_rate(tick, :EUREUR))
        .to eq 1
      expect(pricing_utils.calculate_current_counter_rate(tick, :USDUSD))
        .to eq 1
    end
  end

end
