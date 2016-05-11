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

  def create_mock_position(expect_to_receive_close, pair_name)
    mock = double('mock position')
    expect(mock).to receive(:close).at_least(:once) if expect_to_receive_close
    allow(mock).to receive(:pair_name).and_return(pair_name)
    mock
  end

end
