# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Notification::Notification do
  include_context 'use backtests'
  let(:agent_setting) do
    data_builder.register_agent_setting
  end

  it 'Notificationを作成して永続化できる' do
    actions = [
      { 'label' => 'あ', 'action' => 'aaa' },
      { 'label' => 'い', 'action' => 'bbb' }
    ]
    notification = Jiji::Model::Notification::Notification.create(
      agent_setting, Time.at(100), nil, 'message', actions)

    expect(notification.backtest_id).to be nil
    expect(notification.agent_id).to eq agent_setting.id
    expect(notification.agent.name).to eq 'test1'
    expect(notification.agent.icon_id).to eq agent_setting.icon_id
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq 'message'
    expect(notification.actions).to eq actions

    notification.save

    notification = Jiji::Model::Notification::Notification.find(notification.id)
    expect(notification.backtest_id).to be nil
    expect(notification.agent_id).to eq agent_setting.id
    expect(notification.agent.name).to eq 'test1'
    expect(notification.agent.icon_id).to eq agent_setting.icon_id
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq 'message'
    expect(notification.actions).to eq actions

    notification = Jiji::Model::Notification::Notification.create(
      agent_setting, Time.at(200), backtests[0], 'message2', actions)

    expect(notification.backtest_id).to be backtests[0].id
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
      agent_setting.id,  Time.at(100), nil, 'message', actions)

    expect(notification.to_h).to eq({
      id:          notification.id,
      backtest_id: nil,
      agent:       {
        id:      agent_setting.id,
        icon_id: agent_setting.icon_id,
        name:    'test1'
      },
      timestamp:   Time.at(100),
      message:     'message',
      actions:     actions,
      read_at:     nil
    })
  end
end
