# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/utils/requires'

describe Jiji::Model::Trading::BackTest do
  include_context 'use data_builder'
  include_context 'use container'

  let(:backtest_repository)     { container.lookup(:backtest_repository) }
  let(:agent_registory)         { container.lookup(:agent_registry) }
  let(:position_repository)     { container.lookup(:position_repository) }
  let(:graph_repository)        { container.lookup(:graph_repository) }
  let(:notification_repository) { container.lookup(:notification_repository) }

  before(:example) do
    backtest_repository.load

    root = Jiji::Utils::Requires.root
    %w[signals moving_average_agent cross].each do |file|
      source = agent_registory.add_source("#{file}.rb", '', :agent,
        IO.read("#{root}/src/jiji/model/agents/builtin_files/#{file}.rb"))
      raise source.error unless source.error.nil?
    end
    %w[error_agent].each do |file|
      f = File.expand_path("../../agents/builtin_files/#{file}.rb", __FILE__)
      source = agent_registory.add_source("#{file}.rb", '', :agent, IO.read(f))
      raise source.error unless source.error.nil?
    end
  end

  after(:example) do
    backtest_repository.stop
    Mail::TestMailer.deliveries.clear
  end

  it 'バックテストを実行できる' do
    test = backtest_repository.register({
      'name' => 'テスト',
      'start_time' => Time.new(2015, 6, 20, 0, 0, 0),
      'end_time' => Time.new(2015, 6, 20, 1, 0, 0),
      'memo' => 'メモ',
      'pair_names' => %i[USDJPY EURUSD],
      'agent_setting' => [
        {
          agent_class: 'MovingAverageAgent@moving_average_agent.rb',
          agent_name:  'テスト1',
          properties:  { 'short' => 25, 'long' => 75 }
        }, {
          agent_class: 'MovingAverageAgent@moving_average_agent.rb',
          agent_name:  'テスト2',
          properties:  { 'short' => 40, 'long' => 80 }
        }
      ]
    })

    sleep 0.2 until test.process.finished?

    expect(test.retrieve_process_status).to be :finished

    graphs = graph_repository.find(test._id).map { |g| g }
    expect(graphs.length).to be 2
    expect(graphs[0].backtest_id).to eq test._id
    expect(graphs[0].label).to eq '口座資産'
    expect(graphs[0].colors).to eq []
    expect(graphs[1].backtest_id).to eq test._id
    expect(graphs[1].label).to eq '移動平均線'
    expect(graphs[1].colors).to eq ['#779999', '#557777']

    data = graphs[0].fetch_data(
      Time.new(2015, 6, 20, 0,  0, 0),
      Time.new(2015, 6, 20, 1,  0, 0)).map { |d| d }
    expect(data.length).to be > 0

    positions = position_repository.retrieve_positions(
      test._id, { entered_at: :asc }, 0, 10)
      .select { |p| p.agent.name == 'テスト1' }
    expect(positions.length).to be > 0
    positions.each do |position|
      expect(position.agent.name).to eq 'テスト1'
      expect(position.agent_id).not_to be nil
    end

    positions = position_repository.retrieve_positions(
      test._id, { entered_at: :asc }, 0, 10)
      .select { |p| p.agent.name == 'テスト2' }
    expect(positions.length).to be > 0
    positions.each do |position|
      expect(position.agent.name).to eq 'テスト2'
      expect(position.agent_id).not_to be nil
    end
  end

  it 'メール、push通知を送信できる' do
    icon_id = BSON::ObjectId.from_time(Time.new)
    test = backtest_repository.register({
      'name' => 'テスト',
      'start_time' => Time.new(2015, 6, 20, 0, 0, 0),
      'end_time' => Time.new(2015, 6, 20, 0, 1, 0),
      'memo' => 'メモ',
      'pair_names' => %i[USDJPY EURUSD],
      'agent_setting' => [
        {
          agent_class: 'SendNotificationAgent@error_agent.rb',
          agent_name:  'テスト1',
          icon_id:     icon_id
        }
      ]
    })

    sleep 0.2 until test.process.finished?
    expect(test.retrieve_process_status).to be :finished

    expect(Mail::TestMailer.deliveries.length).to eq 2
    expect(Mail::TestMailer.deliveries[0].subject).to eq 'テスト'
    expect(Mail::TestMailer.deliveries[0].to).to eq ['foo@example.com']
    expect(Mail::TestMailer.deliveries[0].from).to eq ['jiji@unageanu.net']
    expect(Mail::TestMailer.deliveries[1].subject).to eq 'テスト2'
    expect(Mail::TestMailer.deliveries[1].to).to eq ['foo@example.com']
    expect(Mail::TestMailer.deliveries[1].from).to eq ['jiji@unageanu.net']

    notifications = notification_repository.retrieve_notifications(
      { backtest_id: test.id }, { timestamp: :asc, id: :asc })
    expect(notifications.length).to eq 2
    notification = notifications[0]
    expect(notification.backtest_id).to eq test.id
    expect(notification.timestamp).not_to be nil
    expect(notification.message).to eq 'テスト通知'
    expect(notification.agent_id).not_to be nil
    expect(notification.agent.name).to eq 'テスト1'
    expect(notification.agent.icon_id).to eq icon_id
    expect(notification.actions).to eq []

    notification = notifications[1]
    expect(notification.backtest_id).to eq test.id
    expect(notification.timestamp).not_to be nil
    expect(notification.message).to eq 'テスト通知2'
    expect(notification.agent_id).not_to be nil
    expect(notification.agent.name).to eq 'テスト1'
    expect(notification.agent.icon_id).to eq icon_id
    expect(notification.actions).to eq []
  end

  it 'エラーが発生すると実行がキャンセルされる' do
    test = backtest_repository.register({
      'name' => 'テスト',
      'start_time' => Time.new(2015, 6, 20, 0, 0, 0),
      'end_time' => Time.new(2015, 6, 20, 1, 0, 0),
      'memo' => 'メモ',
      'pair_names' => %i[USDJPY EURUSD],
      'agent_setting' => [
        {
          agent_class: 'ErrorAgent@error_agent.rb',
          properties:  { 'short' => 25, 'long' => 75 }
        }
      ]
    })
    test.to_h

    sleep 0.2 until test.process.finished?
    expect(test.retrieve_process_status).to be :error

    backtest_repository.register({
      'name' => 'テスト',
      'start_time' => Time.new(2015, 6, 20, 0, 0, 0),
      'end_time' => Time.new(2015, 6, 20, 1, 0, 0),
      'memo' => 'メモ',
      'pair_names' => %i[USDJPY EURUSD],
      'agent_setting' => [
        {
          agent_class: 'ErrorOnCreateAgent@error_agent.rb'
        }
      ]
    })
    test.to_h

    sleep 0.2 until test.process.finished?
    expect(test.retrieve_process_status).to be :error

    backtest_repository.register({
      'name' => 'テスト',
      'start_time' => Time.new(2015, 6, 20, 0, 0, 0),
      'end_time' => Time.new(2015, 6, 20, 1, 0, 0),
      'memo' => 'メモ',
      'pair_names' => %i[USDJPY EURUSD],
      'agent_setting' => [
        {
          agent_class: 'ErrorOnPostCreateAgent@error_agent.rb'
        }
      ]
    })
    test.to_h

    sleep 0.2 until test.process.finished?
    expect(test.retrieve_process_status).to be :error
  end
end
