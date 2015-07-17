# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Notification::Notification do
  let(:data_builder) { Jiji::Test::DataBuilder.new }

  let(:container) { Jiji::Test::TestContainerFactory.instance.new_container }
  let(:backtest) do
    agent_registry      = container.lookup(:agent_registry)
    backtest_repository = container.lookup(:backtest_repository)
    agent_registry.add_source('aaa', '', :agent,
      data_builder.new_agent_body(1))
    data_builder.register_backtest(1, backtest_repository)
  end

  after(:example) do
    data_builder.clean
  end

  after(:example) do
    data_builder.clean
  end

  it 'Notificationを作成して永続化できる' do
    actions = [
      { "label" => "あ", "action" => "aaa" },
      { "label" => "い", "action" => "bbb" }
    ]
    notification = Jiji::Model::Notification::Notification.create(
      "a", "test1", Time.at(100), nil, "message", "icon", actions)

    expect(notification.backtest_id).to be nil
    expect(notification.agent_id).to eq "a"
    expect(notification.agent_name).to eq "test1"
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq "message"
    expect(notification.icon).to eq "icon"
    expect(notification.actions).to eq actions

    notification.save

    notification = Jiji::Model::Notification::Notification.find(notification.id)
    expect(notification.backtest_id).to be nil
    expect(notification.agent_id).to eq "a"
    expect(notification.agent_name).to eq "test1"
    expect(notification.timestamp).to eq Time.at(100)
    expect(notification.message).to eq "message"
    expect(notification.icon).to eq "icon"
    expect(notification.actions).to eq actions


    notification = Jiji::Model::Notification::Notification.create(
      "b", "test2", Time.at(200), backtest.id, "message2", "icon2", actions)

    expect(notification.backtest_id).to be backtest.id
    expect(notification.agent_id).to eq "b"
    expect(notification.agent_name).to eq "test2"
    expect(notification.timestamp).to eq Time.at(200)
    expect(notification.message).to eq "message2"
    expect(notification.icon).to eq "icon2"
    expect(notification.actions).to eq actions
  end

  it 'read で既読状態にできる' do
    actions = [
      { "label" => "あ", "action" => "aaa" },
      { "label" => "い", "action" => "bbb" }
    ]
    notification = Jiji::Model::Notification::Notification.create(
      "a", "test1", Time.at(100), nil, "message", "icon", actions)

    expect(notification.read?).to eq false

    notification.read(Time.at(200))
    expect(notification.read?).to eq true

    notification = Jiji::Model::Notification::Notification.find(notification.id)
    expect(notification.read?).to eq true
  end

  it 'to_hでハッシュに変換できる' do
    actions = [
      { "label" => "あ", "action" => "aaa" },
      { "label" => "い", "action" => "bbb" }
    ]
    notification = Jiji::Model::Notification::Notification.create(
      "a", "test1", Time.at(100), nil, "message", "icon", actions)

    expect(notification.to_h).to eq({
      backtest_id:    nil,
      agent_id:       "a",
      agent_name:     "test1",
      timestamp:      Time.at(100),
      message:        "message",
      icon:           "icon",
      actions:        actions,
      read_at:        nil
    })
  end
end
