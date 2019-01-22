# frozen_string_literal: true

module Jiji::Test
  def self.same_position?(a, b)
    values_a = extract_position_values_without_id(a)
    values_b = extract_position_values_without_id(b)
    values_a == values_b
  end

  def self.extract_position_values_without_id(p)
    [
      p.pair_name, p.units, p.sell_or_buy, p.status,
      p.entry_price, p.entered_at, p.current_price, p.updated_at,
      p.exit_price, p.exited_at, p.closing_policy, p.profit_or_loss,
      p.agent_id, p.current_counter_rate
    ]
  end

  def self.same_position_ignore_current_price?(a, b)
    values_a = extract_position_values_ignore_current_price(a)
    values_b = extract_position_values_ignore_current_price(b)
    values_a == values_b
  end

  def self.extract_position_values_ignore_current_price(p)
    [
      p.pair_name, p.units, p.sell_or_buy, p.status,
      p.entry_price, p.entered_at, p.exit_price, p.exited_at,
      p.closing_policy.take_profit, p.closing_policy.stop_loss,
      p.closing_policy.trailing_stop, p.agent_id
    ]
  end

  def self.same_order?(a, b)
    values_a = extract_order_values_without_id(a)
    values_b = extract_order_values_without_id(b)
    values_a == values_b
  end

  def self.extract_order_values_without_id(o)
    o.values
  end
end

RSpec::Matchers.define :same_position do |expected|
  match do |actual|
    Jiji::Test.same_position?(actual, expected)
  end
end

RSpec::Matchers.define :same_position_ignore_current_price do |expected|
  match do |actual|
    Jiji::Test.same_position_ignore_current_price?(actual, expected)
  end
end

RSpec::Matchers.define :same_order do |expected|
  match do |actual|
    Jiji::Test.same_order?(actual, expected)
  end
end
