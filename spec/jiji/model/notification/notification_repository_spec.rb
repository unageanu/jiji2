# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Notification::NotificationRepository do
  let(:data_builder) { Jiji::Test::DataBuilder.new }

  let(:container) { Jiji::Test::TestContainerFactory.instance.new_container }
  let(:backtests) do
    agent_registry      = container.lookup(:agent_registry)
    backtest_repository = container.lookup(:backtest_repository)
    agent_registry.add_source('aaa', '', :agent,
      data_builder.new_agent_body(1))
    return [
      data_builder.register_backtest(1, backtest_repository),
      data_builder.register_backtest(2, backtest_repository)
    ]
  end
  let(:notification_repository) { container.lookup(:notification_repository) }

  before(:example) do
    register_notifications
    register_notifications(backtests[0]._id)
  end

  after(:example) do
    data_builder.clean
  end

  def register_notifications(backtest_id=nil)
    100.times do |i|
      notification = data_builder.new_notification(i, backtest_id)
      notification.save
    end
  end

  it 'ソート条件、取得数を指定して、一覧を取得できる' do
    notifications = notification_repository.retrieve_notifications(nil)

    expect(notifications.length).to eq(20)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(0))
    expect(notifications[19].backtest_id).to eq(nil)
    expect(notifications[19].timestamp).to eq(Time.at(19))

    notifications = notification_repository.retrieve_notifications(
      nil, timestamp: :desc)

    expect(notifications.size).to eq(20)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(99))
    expect(notifications[19].backtest_id).to eq(nil)
    expect(notifications[19].timestamp).to eq(Time.at(80))

    notifications = notification_repository.retrieve_notifications(
      nil, { timestamp: :desc }, 10, 30)

    expect(notifications.size).to eq(30)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(89))
    expect(notifications[29].backtest_id).to eq(nil)
    expect(notifications[29].timestamp).to eq(Time.at(60))

    notifications = notification_repository.retrieve_notifications(
      nil, { timestamp: :asc }, 10, 30)

    expect(notifications.size).to eq(30)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(10))
    expect(notifications[29].backtest_id).to eq(nil)
    expect(notifications[29].timestamp).to eq(Time.at(39))

    notifications = notification_repository.retrieve_notifications(
      backtests[0]._id)

    expect(notifications.size).to eq(20)
    expect(notifications[0].backtest_id).to eq(backtests[0]._id)
    expect(notifications[0].timestamp).to eq(Time.at(0))
    expect(notifications[19].backtest_id).to eq(backtests[0]._id)
    expect(notifications[19].timestamp).to eq(Time.at(19))

    notifications = notification_repository.retrieve_notifications(
      backtests[1]._id)
    expect(notifications.size).to eq(0)
  end

  it '検索条件を指定して、一覧を取得できる' do
    notifications = notification_repository.retrieve_notifications(nil,
      { timestamp: :asc, id: :asc }, nil, nil, {
      :timestamp.gt => Time.at(30)
    })

    expect(notifications.length).to eq(69)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(31))
    expect(notifications[68].backtest_id).to eq(nil)
    expect(notifications[68].timestamp).to eq(Time.at(99))
  end

  it '通知の総数を取得できる' do
    count = notification_repository.count_notifications
    expect(count).to eq(100)

    count = notification_repository.count_notifications(backtests[0]._id)
    expect(count).to eq(100)

    count = notification_repository.count_notifications(nil, {
      :timestamp.gt => Time.at(30)
    })
    expect(count).to eq(69)
  end

  it '指定日時以前のRMTの通知を削除できる'  do
    notifications = notification_repository.retrieve_notifications
    expect(notifications.size).to eq(20)

    notification_repository.delete_notifications_of_rmt(Time.at(40))

    notifications = notification_repository.retrieve_notifications
    expect(notifications.size).to eq(20)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(40))
    expect(notifications[19].backtest_id).to eq(nil)
    expect(notifications[19].timestamp).to eq(Time.at(59))

    notification_repository.delete_notifications_of_rmt(Time.at(60))

    notifications = notification_repository.retrieve_notifications
    expect(notifications.size).to eq(20)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(60))
    expect(notifications[19].backtest_id).to eq(nil)
    expect(notifications[19].timestamp).to eq(Time.at(79))
  end
end
