# coding: utf-8

require 'sample_agent_test_configuration'

describe RangeBreakChecker do
  include_context 'use agent_setting'

  let(:pairs) do
    [
      Jiji::Model::Trading::Pair.new(
        :USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04),
      Jiji::Model::Trading::Pair.new(
        :EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04)
    ]
  end

  it 'periodの期間、レートがrange_pipsで推移した後、'\
     '上に抜けるとレンジブレイクする' do
    checker = RangeBreakChecker.new(pairs[0], 60 * 8, 100)

    # データが不足している状態では ブレイクしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.25, 0.03)
    }, Time.new(2016, 1, 10, 0)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 1)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.46, 0.03)
    }, Time.new(2016, 1, 10, 2)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.059, 0.03)
    }, Time.new(2016, 1, 10, 3)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.37, 0.03)
    }, Time.new(2016, 1, 10, 4)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.16, 0.03)
    }, Time.new(2016, 1, 10, 5)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.06, 0.03)
    }, Time.new(2016, 1, 10, 6)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 7)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.76, 0.03)
    }, Time.new(2016, 1, 10, 8)))
    expect(result[:state]).to be :no

    # データが貯まっても、上or下に抜けないとブレイクはしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.80, 0.03)
    }, Time.new(2016, 1, 10, 9)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.059, 0.03)
    }, Time.new(2016, 1, 10, 10)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.06, 0.03)
    }, Time.new(2016, 1, 10, 11)))
    expect(result[:state]).to be :break_high

    # 一度ブレイクすると、高値を更新しても再ブレイクはしない
    # 再度データがたまるまでブレイクはしない。
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.07, 0.03)
    }, Time.new(2016, 1, 10, 12)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.80, 0.03)
    }, Time.new(2016, 1, 10, 17)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.22, 0.03)
    }, Time.new(2016, 1, 10, 20)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.21, 0.03)
    }, Time.new(2016, 1, 10, 21)))
    expect(result[:state]).to be :break_low

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.22, 0.03)
    }, Time.new(2016, 1, 10, 21)))
    expect(result[:state]).to be :no
  end

  it 'periodの期間、レートがrange_pipsで推移した後、'\
     '下に抜けるとレンジブレイクする' do
    checker = RangeBreakChecker.new(pairs[0], 60 * 8, 100)

    # データが不足している状態では ブレイクしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.25, 0.03)
    }, Time.new(2016, 1, 10, 0)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 1)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.46, 0.03)
    }, Time.new(2016, 1, 10, 2)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.059, 0.03)
    }, Time.new(2016, 1, 10, 3)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.37, 0.03)
    }, Time.new(2016, 1, 10, 4)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.16, 0.03)
    }, Time.new(2016, 1, 10, 5)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.06, 0.03)
    }, Time.new(2016, 1, 10, 6)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 7)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.76, 0.03)
    }, Time.new(2016, 1, 10, 8)))
    expect(result[:state]).to be :no

    # データが貯まっても、上or下に抜けないとブレイクはしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.10, 0.03)
    }, Time.new(2016, 1, 10, 9)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.06, 0.03)
    }, Time.new(2016, 1, 10, 10)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.059, 0.03)
    }, Time.new(2016, 1, 10, 11)))
    expect(result[:state]).to be :break_low

    # 一度ブレイクすると、高値を更新しても再ブレイクはしない
    # 再度データがたまるまでブレイクはしない。
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.05, 0.03)
    }, Time.new(2016, 1, 10, 12)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.80, 0.03)
    }, Time.new(2016, 1, 10, 17)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.60, 0.03)
    }, Time.new(2016, 1, 10, 20)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.00, 0.03)
    }, Time.new(2016, 1, 10, 21)))
    expect(result[:state]).to be :break_high

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.07, 0.03)
    }, Time.new(2016, 1, 10, 21)))
    expect(result[:state]).to be :no
  end

  it 'レートがrange_pips外になっても、' \
     '外れたところからrange_periodの期間が過ぎればブレイクする' do
    checker = RangeBreakChecker.new(pairs[0], 60 * 8, 100)

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.25, 0.03)
    }, Time.new(2016, 1, 10, 0)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 0, 1)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.66, 0.03)
    }, Time.new(2016, 1, 10, 0, 2)))
    expect(result[:state]).to be :no

    # 上に抜ける
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.36, 0.03)
    }, Time.new(2016, 1, 10, 2)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.25, 0.03)
    }, Time.new(2016, 1, 10, 2, 1)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.58, 0.03)
    }, Time.new(2016, 1, 10, 3)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.37, 0.03)
    }, Time.new(2016, 1, 10, 4)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.16, 0.03)
    }, Time.new(2016, 1, 10, 5)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.06, 0.03)
    }, Time.new(2016, 1, 10, 6)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.16, 0.03)
    }, Time.new(2016, 1, 10, 6, 2)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 7)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.76, 0.03)
    }, Time.new(2016, 1, 10, 8)))
    expect(result[:state]).to be :no

    # 02:00 121.36, 06:00 120.06 がrangeに収まっていないためブレイクしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.10, 0.03)
    }, Time.new(2016, 1, 10, 8, 10)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.20, 0.03)
    }, Time.new(2016, 1, 10, 8, 11)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.00, 0.03)
    }, Time.new(2016, 1, 10, 8, 15)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.7, 0.03)
    }, Time.new(2016, 1, 10, 9)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.4, 0.03)
    }, Time.new(2016, 1, 10, 10)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.6, 0.03)
    }, Time.new(2016, 1, 10, 11)))
    expect(result[:state]).to be :no

    # 02:00 121.36 のピークが外れる。
    # が、08:11 121.20　06:00 120.06 がrangeを外しているのでブレイクしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.21, 0.03)
    }, Time.new(2016, 1, 10, 12)))
    expect(result[:state]).to be :no

    # 12:00 121.21　06:00 120.06
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.91, 0.03)
    }, Time.new(2016, 1, 10, 13)))
    expect(result[:state]).to be :no

    # 12:00 121.21　06:00 120.06
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.81, 0.03)
    }, Time.new(2016, 1, 10, 14)))
    expect(result[:state]).to be :no

    # 12:00 121.21　06:00 120.06
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.91, 0.03)
    }, Time.new(2016, 1, 10, 15)))
    expect(result[:state]).to be :no

    # 12:00 121.21　07:00 120.36
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.92, 0.03)
    }, Time.new(2016, 1, 10, 16)))
    expect(result[:state]).to be :no

    # 12:00 121.21　10:00 120.4
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.21, 0.03)
    }, Time.new(2016, 1, 10, 17)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.41, 0.03)
    }, Time.new(2016, 1, 10, 18)))
    expect(result[:state]).to be :break_high

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.35, 0.03)
    }, Time.new(2016, 1, 10, 19)))
    expect(result[:state]).to be :no
  end

  it '状態を永続化して復元できる' do
    checker = RangeBreakChecker.new(pairs[0], 60 * 8, 100)

    # データが不足している状態では ブレイクしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.25, 0.03)
    }, Time.new(2016, 1, 10, 0)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 1)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.46, 0.03)
    }, Time.new(2016, 1, 10, 2)))
    expect(result[:state]).to be :no

    checker = recreate(checker)

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.059, 0.03)
    }, Time.new(2016, 1, 10, 3)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.37, 0.03)
    }, Time.new(2016, 1, 10, 4)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.16, 0.03)
    }, Time.new(2016, 1, 10, 5)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.06, 0.03)
    }, Time.new(2016, 1, 10, 6)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.36, 0.03)
    }, Time.new(2016, 1, 10, 7)))
    expect(result[:state]).to be :no

    checker = recreate(checker)

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.76, 0.03)
    }, Time.new(2016, 1, 10, 8)))
    expect(result[:state]).to be :no

    # データが貯まっても、上or下に抜けないとブレイクはしない
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.80, 0.03)
    }, Time.new(2016, 1, 10, 9)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.059, 0.03)
    }, Time.new(2016, 1, 10, 10)))
    expect(result[:state]).to be :no

    checker = recreate(checker)

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.06, 0.03)
    }, Time.new(2016, 1, 10, 11)))
    expect(result[:state]).to be :break_high

    checker = recreate(checker)

    # 一度ブレイクすると、高値を更新しても再ブレイクはしない
    # 再度データがたまるまでブレイクはしない。
    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.07, 0.03)
    }, Time.new(2016, 1, 10, 12)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.80, 0.03)
    }, Time.new(2016, 1, 10, 17)))
    expect(result[:state]).to be :no

    checker = recreate(checker)

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(121.22, 0.03)
    }, Time.new(2016, 1, 10, 20)))
    expect(result[:state]).to be :no

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.21, 0.03)
    }, Time.new(2016, 1, 10, 21)))
    expect(result[:state]).to be :break_low

    result = checker.check_range_break(Jiji::Model::Trading::Tick.new({
      USDJPY: new_tick_value(120.22, 0.03)
    }, Time.new(2016, 1, 10, 21)))
    expect(result[:state]).to be :no
  end

  def recreate(checker)
    state = checker.state
    checker = RangeBreakChecker.new(pairs[0], 60 * 8, 100)
    checker.restore_state(state)
    checker
  end

  def new_tick_value(bid, spread)
    Jiji::Model::Trading::Tick::Value.new(
      bid, BigDecimal.new(bid, 10) + spread)
  end
end
