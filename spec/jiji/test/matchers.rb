
module Jiji::Test
  def self.some_position?(a, b)
    values_a = extract_position_values_without_id(a)
    values_b = extract_position_values_without_id(b)
    values_a == values_b
  end

  def self.extract_position_values_without_id(p)
    [
      p.pair_name, p.units, p.sell_or_buy, p.status,
      p.entry_price, p.entered_at, p.current_price, p.updated_at,
      p.exit_price, p.exited_at, p.closing_policy, p.profit_or_loss
    ]
  end
end

RSpec::Matchers.define :some_position do |expected|
  match do |actual|
    Jiji::Test.some_position?(actual, expected)
  end
end
