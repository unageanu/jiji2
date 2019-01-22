# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Model::Notification::Notification do
  include_context 'use agent_setting'

  it 'Notificationを作成して永続化できる' do
    actions = [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ]
    notification = Jiji::Model::Notification::Notification.create(
      agent_setting, Time.at(100), nil, 'message', actions)

    expect(notification.backtest).to be nil
    expect(notification.agent_id).to eq agent_setting.id
    expect(notification.agent.name).to eq 'test1'
    expect(notification.agent.icon_id).to eq agent_setting.icon_id
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq 'message'
    expect(notification.actions).to eq actions

    notification.save

    notification = Jiji::Model::Notification::Notification.find(notification.id)
    expect(notification.backtest).to be nil
    expect(notification.agent_id).to eq agent_setting.id
    expect(notification.agent.name).to eq 'test1'
    expect(notification.agent.icon_id).to eq agent_setting.icon_id
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq 'message'
    expect(notification.actions).to eq actions

    notification = Jiji::Model::Notification::Notification.create(
      agent_setting, Time.at(200), backtests[0], 'message2', actions)

    expect(notification.backtest).to eq backtests[0]
    expect(notification.agent_id).to eq agent_setting.id
    expect(notification.agent.name).to eq 'test1'
    expect(notification.agent.icon_id).to eq agent_setting.icon_id
    expect(notification.timestamp).to eq Time.at(200)
    expect(notification.message).to eq 'message2'
    expect(notification.actions).to eq actions
  end

  it 'read で既読状態にできる' do
    actions = [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ]
    notification = Jiji::Model::Notification::Notification.create(
      agent_setting.id, Time.at(100), nil, 'message', actions)

    expect(notification.read?).to eq false

    notification.read(Time.at(200))
    expect(notification.read?).to eq true

    notification = Jiji::Model::Notification::Notification.find(notification.id)
    expect(notification.read?).to eq true
  end

  it 'to_hでハッシュに変換できる' do
    actions = [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ]
    notification = Jiji::Model::Notification::Notification.create(
      agent_setting.id, Time.at(100), backtests[0], 'message', actions,
      'ノート', { chart: { pair: :EURJPY } })

    expect(notification.to_h).to eq({
      id:        notification.id,
      backtest:  {
        id:   backtests[0].id,
        name: 'テスト1'
      },
      agent:     {
        id:      agent_setting.id,
        icon_id: agent_setting.icon_id,
        name:    'test1'
      },
      timestamp: Time.at(100),
      message:   'message',
      actions:   actions,
      read_at:   nil,
      note:      'ノート',
      options:   { chart: { pair: :EURJPY } }
    })

    notification = Jiji::Model::Notification::Notification.create(
      nil, Time.at(100), nil, 'message', actions)

    expect(notification.to_h).to eq({
      id:        notification.id,
      backtest:  {
      },
      agent:     {
      },
      timestamp: Time.at(100),
      message:   'message',
      actions:   actions,
      read_at:   nil,
      note:      nil,
      options:   nil
    })
  end

  it 'titleが70文字を超える場合、先頭70文字が使われる' do
    notification = Jiji::Model::Notification::Notification.create(
      agent_setting,  Time.at(100), backtests[0], 'message')

    expect(notification.title).to eq('test1 | テスト1')

    backtests[0].name = 'い' * 50
    agent_setting.name = 'あ' * 50
    expect(notification.title).to eq("#{'あ' * 50} | #{'い' * 17}")

    notification = Jiji::Model::Notification::Notification.create(
      agent_setting,  Time.at(100), nil, 'message')

    expect(notification.title).to eq("#{'あ' * 50} | リアルトレード")

    agent_setting.name = 'あ' * 100
    expect(notification.title).to eq(('あ' * 70).to_s)
  end
end
