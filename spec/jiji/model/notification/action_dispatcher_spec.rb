# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Notification::NotificationRepository do
  include_context 'use data_builder'
  include_context 'use container'
  let(:notification_repository) { container.lookup(:notification_repository) }
  let(:action_dispatcher) { container.lookup(:action_dispatcher) }

  before(:example) do
    agent_registry = container.lookup(:agent_registry)
    agent_registry.add_source('aaa', '', :agent,
      data_builder. new_notification_agent_body(1))
  end

  RSpec.shared_examples 'アクションの実行' do
    it 'アクションを実行できる' do
      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtest_id
      })
      expect(notifications.length).to eq(1)
      notification = notifications[0]
      expect(notification.backtest_id).to eq backtest_id
      expect(notification.message).to eq('テスト通知')
      expect(notification.actions).to eq([
        { 'label' => 'アクション1', 'action' => 'aaa' },
        { 'label' => 'アクション2', 'action' => 'bbb' }
      ])

      action_dispatcher.dispatch(
        notification.backtest_id, notification.agent_id, 'aaa').value

      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtest_id
      })
      expect(notifications.length).to eq(2)
      notification = notifications[0]
      expect(notification.message).to eq('do action aaa')
      expect(notification.actions).to eq([])
    end

    it 'アクション実行でエラーになってもプロセスは停止しない' do
      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtest_id
      })
      expect(notifications.length).to eq(1)
      notification = notifications[0]

      expect do
        action_dispatcher.dispatch(
          notification.backtest_id, notification.agent_id, 'error').value
      end.to raise_error

      action_dispatcher.dispatch(
        notification.backtest_id, notification.agent_id, 'bbb').value

      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtest_id
      })
      expect(notifications.length).to eq(2)
      notification = notifications[0]
      expect(notification.message).to eq('do action bbb')
      expect(notification.actions).to eq([])
    end

    it 'エージェントが存在しない場合、エラーになる' do
      expect do
        action_dispatcher.dispatch(
          backtest_id, 'not_found', 'aaa').value
      end.to raise_error(Jiji::Errors::NotFoundException)
    end
  end

  describe 'rmt' do
    let(:target) do
      container.lookup(:rmt)
    end
    let(:backtest_id) { nil }

    before(:example) do
      target.setup
      target.update_agent_setting([{
        agent_class: 'TestAgent1@aaa',
        agent_name:  'テスト1'
      }])
    end

    after(:example) do
      target.tear_down
    end

    it_behaves_like 'アクションの実行'
  end

  describe 'backtest' do
    let(:target) do
      backtest_repository = container.lookup(:backtest_repository)
      return data_builder.register_backtest(1,
        backtest_repository, Time.at(0), Time.at(60 * 60 * 1000))
    end
    let(:backtest_id) { target.id }

    it_behaves_like 'アクションの実行'

    it 'バックテストが存在しない場合、エラーになる' do
      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtest_id
      })
      expect(notifications.length).to eq(1)
      notification = notifications[0]

      expect do
        action_dispatcher.dispatch(
          'not_found', notification.agent_id, 'aaa').value
      end.to raise_error(Jiji::Errors::NotFoundException)
    end

    it 'テストの実行が完了していてもアクションを実行できる' do
      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtest_id
      })
      expect(notifications.length).to eq(1)
      notification = notifications[0]

      sleep 1 while target.process.finished?

      action_dispatcher.dispatch(
        notification.backtest_id, notification.agent_id, 'aaa').value

      notifications = notification_repository.retrieve_notifications({
        backtest_id: backtest_id
      })
      expect(notifications.length).to eq(2)
      notification = notifications[0]
      expect(notification.message).to eq('do action aaa')
      expect(notification.actions).to eq([])
    end
  end
end
