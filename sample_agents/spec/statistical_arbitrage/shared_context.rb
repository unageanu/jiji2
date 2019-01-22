# frozen_string_literal: true

RSpec.shared_context 'utils for statistical arbitrage' do
  def create_tick(aud, nzd, time = Time.utc(2015, 5, 1, 3, 0, 0))
    Jiji::Model::Trading::Tick.new({
      AUDJPY: new_tick_value(aud),
      NZDJPY: new_tick_value(nzd)
    }, time)
  end

  def new_tick_value(value)
    Jiji::Model::Trading::Tick::Value.new(
      BigDecimal(value, 10).to_f,
      (BigDecimal(value, 10) + 0.03).to_f)
  end

  def create_mock_position(pair_name,
    sell_or_buy = :sell, units = 5000)
    {
      'pair' => pair_name,
      'units' => units,
      'sell_or_buy' => sell_or_buy
    }
  end
end
