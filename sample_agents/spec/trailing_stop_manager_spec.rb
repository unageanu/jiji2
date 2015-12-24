# coding: utf-8

require 'sample_agent_test_configuration'

describe TrailingStopManager do
  include_context 'use agent_setting'

  let(:builder)    { container.lookup(:position_builder) }
  let(:repository) { container.lookup(:position_repository) }
  let(:original)  do
    tick = Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131, 0.03),
      EURUSD: new_tick_value(1.0935, 0.00005)
    },  Time.new(2015, 12, 10))
    [
      builder.build_from_tick(1, :EURJPY, 10_000, :buy,  tick),
      builder.build_from_tick(2, :EURJPY, 10_000, :sell, tick),
      builder.build_from_tick(3, :EURUSD, 20_000, :buy,  tick)
    ]
  end
  let(:account) do
    Jiji::Model::Trading::Account.new(nil, 1_000_000, 0.04)
  end
  let(:positions) do
    Jiji::Model::Trading::Positions.new(original, builder, account)
  end
  let(:pairs) do
    [
      Jiji::Model::Trading::Pair.new(
        :EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
      Jiji::Model::Trading::Pair.new(
        :EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04)
    ]
  end

  it 'warning_limitを超えない場合、警告の送信も約定もしない' do
    notificator = create_notificator
    manager = TrailingStopManager.new(10, 20, notificator)

    original[0].attach_broker(create_broker(original[0]))
    original[1].attach_broker(create_broker(original[1]))
    original[2].attach_broker(create_broker(original[2]))

    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.94, 0.03),
      EURUSD: new_tick_value(1.0930, 0.00005)
    }, Time.new(2015, 12, 11)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.03, 0.03),
      EURUSD: new_tick_value(1.0940, 0.00005)
    }, Time.new(2015, 12, 12)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.03, 0.03),
      EURUSD: new_tick_value(1.0935, 0.00005)
    }, Time.new(2015, 12, 13)), pairs)
    manager.check(positions, pairs)
  end

  it 'warning_limitを下回ると、警告が送信される' do
    notificator = create_notificator({
      message:  create_message('EURJPY/131.0/売',
        300.0,  Time.new(2015, 12, 11).to_s,
        -800.0, Time.new(2015, 12, 13).to_s),
      position: original[1]
    }, {
      message:  create_message('EURUSD/1.09355/買',
        9.0,  Time.new(2015, 12, 12).to_s,
        -11.0, Time.new(2015, 12, 14).to_s),
      position: original[2]
    }, {
      message:  create_message('EURJPY/131.03/買',
        300.0,  Time.new(2015, 12, 14).to_s,
        -1300.0, Time.new(2015, 12, 15).to_s),
      position: original[0]
    })

    manager = TrailingStopManager.new(10, 20, notificator)

    original[0].attach_broker(create_broker(original[0]))
    original[1].attach_broker(create_broker(original[1]))
    original[2].attach_broker(create_broker(original[2]))

    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.94, 0.03),
      EURUSD: new_tick_value(1.0930, 0.00005)
    }, Time.new(2015, 12, 11)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.03, 0.03),
      EURUSD: new_tick_value(1.0940, 0.00005)
    }, Time.new(2015, 12, 12)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.05, 0.03),
      EURUSD: new_tick_value(1.09301, 0.00005)
    }, Time.new(2015, 12, 13)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.06, 0.03),
      EURUSD: new_tick_value(1.0930, 0.00005)
    }, Time.new(2015, 12, 14)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.9,  0.03),
      EURUSD: new_tick_value(1.0932, 0.00005)
    }, Time.new(2015, 12, 15)), pairs)
    manager.check(positions, pairs)
  end

  it 'closing_limitを下回ると、決済される' do
    notificator = create_notificator({
      message:  create_message('EURJPY/131.0/売',
        -300.0,  Time.new(2015, 12, 10).to_s,
        -1300.0, Time.new(2015, 12, 11).to_s),
      position: original[1]
    })

    manager = TrailingStopManager.new(10, 20, notificator)

    original[0].attach_broker(create_broker(original[0], true))
    original[1].attach_broker(create_broker(original[1], true))
    original[2].attach_broker(create_broker(original[2], true))

    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.10, 0.03),
      EURUSD: new_tick_value(1.0940, 0.00005)
    }, Time.new(2015, 12, 11)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.20, 0.03),
      EURUSD: new_tick_value(1.0945, 0.00005)
    }, Time.new(2015, 12, 12)), pairs)
    manager.check(positions, pairs)

    positions.update([
      original[0], original[2]
    ])

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.999, 0.03),
      EURUSD: new_tick_value(1.0940,  0.00005)
    }, Time.new(2015, 12, 13)), pairs)
    manager.check(positions, pairs)

    positions.update([
      original[2]
    ])

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.8, 0.03),
      EURUSD: new_tick_value(1.0925, 0.00005)
    }, Time.new(2015, 12, 14)), pairs)
    manager.check(positions, pairs)
  end

  it 'state/restore_stateで状態を復元できる' do
    notificator = create_notificator({
      message:  create_message('EURJPY/131.0/売',
        300.0,  Time.new(2015, 12, 11).to_s,
        -800.0, Time.new(2015, 12, 13).to_s),
      position: original[1]
    }, {
      message:  create_message('EURUSD/1.09355/買',
        9.0,  Time.new(2015, 12, 12).to_s,
        -11.0, Time.new(2015, 12, 14).to_s),
      position: original[2]
    }, {
      message:  create_message('EURJPY/131.03/買',
        300.0,  Time.new(2015, 12, 14).to_s,
        -1300.0, Time.new(2015, 12, 15).to_s),
      position: original[0]
    })

    manager = TrailingStopManager.new(10, 20, notificator)

    original[0].attach_broker(create_broker(original[0], true))
    original[1].attach_broker(create_broker(original[1], true))
    original[2].attach_broker(create_broker(original[2], true))

    manager.check(positions, pairs)

    manager = restart(manager, notificator)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.94, 0.03),
      EURUSD: new_tick_value(1.0930, 0.00005)
    }, Time.new(2015, 12, 11)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.03, 0.03),
      EURUSD: new_tick_value(1.0940, 0.00005)
    }, Time.new(2015, 12, 12)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.05, 0.03),
      EURUSD: new_tick_value(1.09301, 0.00005)
    }, Time.new(2015, 12, 13)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.06, 0.03),
      EURUSD: new_tick_value(1.0930, 0.00005)
    }, Time.new(2015, 12, 14)), pairs)
    manager.check(positions, pairs)

    manager = restart(manager, notificator)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.9,  0.03),
      EURUSD: new_tick_value(1.0932, 0.00005)
    }, Time.new(2015, 12, 15)), pairs)
    manager.check(positions, pairs)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(131.20, 0.03),
      EURUSD: new_tick_value(1.0945, 0.00005)
    }, Time.new(2015, 12, 16)), pairs)
    manager.check(positions, pairs)

    positions.update([
      original[0], original[2]
    ])

    manager = restart(manager, notificator)

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.999, 0.03),
      EURUSD: new_tick_value(1.0940,  0.00005)
    }, Time.new(2015, 12, 17)), pairs)
    manager.check(positions, pairs)

    positions.update([
      original[2]
    ])

    positions.update_price(Jiji::Model::Trading::Tick.new({
      EURJPY: new_tick_value(130.8, 0.03),
      EURUSD: new_tick_value(1.0925, 0.00005)
    }, Time.new(2015, 12, 18)), pairs)
    manager.check(positions, pairs)
  end

  it 'process_actionで自身が発行したアクションを処理できる' do
    notificator = create_notificator

    manager = TrailingStopManager.new(10, 20, notificator)

    original[0].attach_broker(create_broker(original[0]))
    original[1].attach_broker(create_broker(original[1], true))
    original[2].attach_broker(create_broker(original[2]))

    manager.check(positions, pairs)

    result = manager.process_action(
      'trailing_stop__close_' + original[1].id.to_s, positions)
    expect(result).to eq '建玉を決済しました。'

    # ポジションが存在しない場合、何もしない。
    result = manager.process_action(
      'trailing_stop__close_not_found', positions)
    expect(result).to eq nil

    # 管轄外のアクションの場合、何もしない。
    result = manager.process_action(
      'unknown', positions)
    expect(result).to eq nil

    result = manager.process_action(
      'trailing_stop__unknown_unknown', positions)
    expect(result).to eq nil
  end

  def create_broker(position, expect_to_close = false)
    broker  = double('mock broker')
    if expect_to_close
      expect(broker).to receive(:close_position)
        .exactly(1).times
        .with(position)
    end
    broker
  end

  def create_notificator(*args)
    notificator = double('mock notificator')
    args.each do |arg|
      expect(notificator).to receive(:push_notification)
        .with(arg[:message], [{
            'label'  => '決済する',
            'action' => 'trailing_stop__close_' + arg[:position].id.to_s
        }])
    end
    notificator
  end

  def create_message(description, max_profit,
    max_profit_time, current_profit, last_update_time)
    "#{description}" \
      + " がトレールストップの閾値を下回りました。決済しますか?\n" \
      + "  最大利益: #{max_profit} #{max_profit_time} \n" \
      + "  現在値: #{current_profit} #{last_update_time}"
  end

  def new_tick_value(bid, spread)
    Jiji::Model::Trading::Tick::Value.new(
      bid, BigDecimal.new(bid, 10) + spread)
  end

  def restart(manager, notificator)
    state = manager.state
    manager = TrailingStopManager.new(10, 20, notificator)
    manager.restore_state(state)
    manager
  end
end
