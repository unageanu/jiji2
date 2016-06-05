# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Utils::PricingUtils do

  include_context 'use data_builder'

  let(:tick) do
    Jiji::Model::Trading::Tick.new({
      EURUSD: data_builder.new_tick_value(1),
      USDJPY: data_builder.new_tick_value(2)
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

end
