RSpec.shared_context 'utils for statistical arbitrage' do

  def create_tick(aud, nzd, time=Time.utc(2015, 5, 1, 3, 0, 0))
    Jiji::Model::Trading::Tick.new({
      AUDJPY: new_tick_value(aud),
      NZDJPY: new_tick_value(nzd)
    }, time)
  end

  def new_tick_value(value)
    Jiji::Model::Trading::Tick::Value.new(
      (BigDecimal.new(value, 10)).to_f,
      (BigDecimal.new(value, 10) + 0.03).to_f)
  end

  def create_mock_position(expect_to_receive_close, pair_name,
    entered_at=Time.utc(2016, 5, 1), sell_or_buy=:sell, entry_price=80)
    mock = double('mock position')
    expect(mock).to receive(:close).at_least(:once) if expect_to_receive_close
    allow(mock).to receive(:pair_name).and_return(pair_name)
    allow(mock).to receive(:entered_at).and_return(entered_at)
    allow(mock).to receive(:sell_or_buy).and_return(sell_or_buy)
    allow(mock).to receive(:entry_price).and_return(entry_price)
    mock
  end

end
