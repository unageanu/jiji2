# coding: utf-8

module Jiji::Model::Trading::Utils
  module PricingUtils
    def self.calculate_entry_price(tick, pair_id, sell_or_buy)
      # 新規エントリー時は、:buy の場合買値で買い、:sell の場合売値で売る。
      calculate_price(tick, pair_id, sell_or_buy)
    end

    def self.calculate_current_price(tick, pair_id, sell_or_buy)
      # 現在価格は、:buy の場合売値、:sell の場合買値で計算。
      calculate_price(tick, pair_id,
        sell_or_buy == :buy ? :sell : :buy)
    end

    def self.calculate_current_counter_rate(tick, counter_pair_id)
      return 1 if counter_pair_id.to_s[0..2] == counter_pair_id.to_s[3..6]
      tick[counter_pair_id].mid
    end

    def self.calculate_price(tick, pair_name, sell_or_buy)
      value = tick[pair_name]
      sell_or_buy == :buy ? value.ask : value.bid
    end
  end
end
