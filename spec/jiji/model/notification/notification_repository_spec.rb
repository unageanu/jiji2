# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Model::Notification::NotificationRepository do
  include_context 'use agent_setting'
  let(:notification_repository) { container.lookup(:notification_repository) }
  before(:example) do
    register_notifications
    register_notifications(backtests[0])
  end

  def register_notifications(backtest = nil)
    100.times do |i|
      notification = data_builder.new_notification(i, agent_setting, backtest)
      notification.save
    end
  end

  it 'ソート条件、取得数を指定して、一覧を取得できる' do
    notifications = notification_repository.retrieve_notifications

    expect(notifications.length).to eq(20)
    expect(notifications[0].timestamp).to eq(Time.at(99))
    expect(notifications[19].timestamp).to eq(Time.at(90))

    notifications = notification_repository.retrieve_notifications(
      {}, { timestamp: :desc, backtest_id: :desc })

    expect(notifications.size).to eq(20)
    expect(notifications[0].backtest_id).to eq(backtests[0].id)
    expect(notifications[0].timestamp).to eq(Time.at(99))
    expect(notifications[19].backtest_id).to eq(nil)
    expect(notifications[19].timestamp).to eq(Time.at(90))

    notifications = notification_repository.retrieve_notifications(
      {}, { timestamp: :desc, backtest_id: :desc }, 10, 30)

    expect(notifications.size).to eq(30)
    expect(notifications[0].backtest_id).to eq(backtests[0].id)
    expect(notifications[0].timestamp).to eq(Time.at(94))
    expect(notifications[29].backtest_id).to eq(nil)
    expect(notifications[29].timestamp).to eq(Time.at(80))

    notifications = notification_repository.retrieve_notifications(
      {}, { timestamp: :asc, backtest_id: :desc }, 10, 30)

    expect(notifications.size).to eq(30)
    expect(notifications[0].backtest_id).to eq(backtests[0].id)
    expect(notifications[0].timestamp).to eq(Time.at(5))
    expect(notifications[29].backtest_id).to eq(nil)
    expect(notifications[29].timestamp).to eq(Time.at(19))
  end

  it '検索条件を指定して、一覧を取得できる' do
    notifications = notification_repository.retrieve_notifications({
      :backtest_id => nil,
      :timestamp.gt => Time.at(30)
    }, { timestamp: :asc, id: :asc }, nil, nil)

    expect(notifications.length).to eq(69)
    expect(notifications[0].backtest_id).to eq(nil)
    expect(notifications[0].timestamp).to eq(Time.at(31))
    expect(notifications[68].backtest_id).to eq(nil)
    expect(notifications[68].timestamp).to eq(Time.at(99))

    notifications = notification_repository.retrieve_notifications({
        :backtest_id => backtests[0].id,
        :timestamp.gt => Time.at(30)
    }, { timestamp: :asc, id: :asc }, nil, nil)

    expect(notifications.length).to eq(69)
    expect(notifications[0].backtest_id).to eq(backtests[0].id)
    expect(notifications[0].timestamp).to eq(Time.at(31))
    expect(notifications[68].backtest_id).to eq(backtests[0].id)
    expect(notifications[68].timestamp).to eq(Time.at(99))
  end

  it '通知の総数を取得できる' do
    count = notification_repository.count_notifications
    expect(count).to eq(200)

    count = notification_repository.count_notifications({
      :backtest_id => nil,
      :timestamp.gt => Time.at(30)
    })
    expect(count).to eq(69)
  end

  describe '#get_by_id' do
    it 'idを指定して通知を取得できる' do
      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtests[0].id
      }, { timestamp: :asc, id: :asc })

      notification = notification_repository.get_by_id(notifications[0])
      expect(notification.backtest.id).to eq(backtests[0].id)
      expect(notification.backtest.name).to eq('テスト1')
      expect(notification.agent.name).to eq('test1')
      expect(notification.timestamp).to eq(Time.at(0))
    end

    it 'idに対応する通知が存在しない場合、エラーになる' do
      expect do
        notification_repository.get_by_id('not_found')
      end.to raise_error(Jiji::Errors::NotFoundException)
    end
  end
end
