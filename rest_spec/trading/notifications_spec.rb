# coding: utf-8

require 'client'

describe '通知取得' do
  before(:context) do
    register_notifications
  end

  after(:context) do
    Jiji::Model::Notification::Notification.drop
    @agent_registry.remove_source('aaa')
  end

  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /notificationsで通知一覧を取得できる' do
    r = @client.get('notifications', {
      'order'       => 'timestamp',
      'direction'   => 'desc',
      'offset'      => 1,
      'limit'       => 10,
      'backtest_id' => 'rmt'
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 2

    notification = r.body[0]
    expect(notification['backtest']).to eq({})
    expect(notification['agent']['id']).not_to be nil
    expect(notification['agent']['name']).to eq 'test1'
    expect(notification['agent']['icon_id']).not_to be nil
    expect(notification['message']).to eq 'message2'
    expect(notification['actions']).to eq []
    expect(notification['note']).to eq nil
    expect(notification['options']).to eq nil
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(200)
    expect(Time.iso8601(notification['read_at'])).to eq Time.at(500)

    notification = r.body[1]
    expect(notification['backtest']).to eq({})
    expect(notification['agent']['id']).not_to be nil
    expect(notification['agent']['name']).to eq 'test1'
    expect(notification['agent']['icon_id']).not_to be nil
    expect(notification['message']).to eq 'message'
    expect(notification['actions']).to eq []
    expect(notification['note']).to eq 'ノート'
    expect(notification['options']).to eq({ 'chart' => { 'pair' => 'EURJPY' } })
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(100)
    expect(notification['read_at']).to be nil

    r = @client.get('notifications', {
      'order'       => 'timestamp',
      'direction'   => 'asc',
      'offset'      => 1,
      'limit'       => 10,
      'backtest_id' => @test._id.to_s
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 2

    notification = r.body[0]
    expect(notification['backtest']['id']).to eq @test._id.to_s
    expect(notification['backtest']['name']).to eq 'テスト1'
    expect(notification['agent']['id']).not_to be nil
    expect(notification['agent']['name']).to eq 'test1'
    expect(notification['agent']['icon_id']).not_to be nil
    expect(notification['message']).to eq 'message2'
    expect(notification['actions']).to eq []
    expect(notification['note']).to eq nil
    expect(notification['options']).to eq nil
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(200)
    expect(Time.iso8601(notification['read_at'])).to eq Time.at(500)

    notification = r.body[1]
    expect(notification['backtest']['id']).to eq @test._id.to_s
    expect(notification['backtest']['name']).to eq 'テスト1'
    expect(notification['agent']['id']).not_to be nil
    expect(notification['agent']['name']).to eq 'test1'
    expect(notification['agent']['icon_id']).not_to be nil
    expect(notification['message']).to eq 'message3'
    expect(notification['actions']).to eq []
    expect(notification['note']).to eq nil
    expect(notification['options']).to eq nil
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(300)
    expect(notification['read_at']).to eq nil

    r = @client.get('notifications', {
      'order'       => 'timestamp',
      'direction'   => 'desc',
      'offset'      => 0,
      'limit'       => 1
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    notification = r.body[0]
    expect(notification['agent']['id']).not_to be nil
    expect(notification['agent']['name']).to eq 'test1'
    expect(notification['agent']['icon_id']).not_to be nil
    expect(notification['message']).to eq 'message3'
    expect(notification['actions']).to eq []
    expect(notification['note']).to eq nil
    expect(notification['options']).to eq nil
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(300)
    expect(notification['read_at']).to eq nil

    r = @client.get('notifications', {
      'order'       => 'timestamp',
      'direction'   => 'desc',
      'offset'      => 0,
      'limit'       => 10,
      'status'      => 'not_read'
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 4

    r.body.each do |n|
      expect(n['agent']['id']).not_to be nil
      expect(n['agent']['name']).to eq 'test1'
      expect(n['agent']['icon_id']).not_to be nil
      expect(n['message']).not_to be nil
      expect(n['actions']).to eq []
      expect(Time.iso8601(n['timestamp'])).not_to be nil
      expect(n['read_at']).to eq nil
    end
  end

  it 'GET /notifications/count 通知の総数を取得できる' do
    r = @client.get('notifications/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 6
    expect(r.body['not_read']).to be 4

    r = @client.get('notifications/count', {
      'backtest_id' => @test._id.to_s
    })
    expect(r.status).to eq 200
    expect(r.body['count']).to be 3
    expect(r.body['not_read']).to be 2

    r = @client.get('notifications/count', {
      'backtest_id' => 'rmt'
    })
    expect(r.status).to eq 200
    expect(r.body['count']).to be 3
    expect(r.body['not_read']).to be 2

    r = @client.get('notifications/count', {
      'backtest_id' => 'rmt',
      'status'      => 'not_read'
    })
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
    expect(r.body['not_read']).to be 2
  end

  it 'GET /notifications/:notificatio_id で通知を取得できる' do
    r = @client.get('notifications', {
      'order'       => 'timestamp',
      'direction'   => 'asc',
      'offset'      => 0,
      'limit'       => 10,
      'backtest_id' => 'rmt'
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 3
    expect(r.body[0]['read_at']).to be nil
    notification_id = r.body[0]['id']

    r = @client.get("notifications/#{notification_id}")
    expect(r.status).to eq 200
    expect(r.body['agent']['id']).not_to be nil
    expect(r.body['agent']['name']).to eq 'test1'
    expect(r.body['agent']['icon_id']).not_to be nil
    expect(r.body['message']).to eq 'message'
    expect(r.body['actions']).to eq []
    expect(r.body['note']).to eq 'ノート'
    expect(r.body['options']).to eq({ 'chart' => { 'pair' => 'EURJPY' } })
    expect(Time.iso8601(r.body['timestamp'])).to eq Time.at(100)
    expect(r.body['read_at']).to eq nil
  end

  it 'PUT /notifications/:notificatio_id/read で通知を既読にできる' do
    r = @client.get('notifications', {
      'order'       => 'timestamp',
      'direction'   => 'asc',
      'offset'      => 0,
      'limit'       => 10,
      'backtest_id' => 'rmt'
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 3
    expect(r.body[0]['read_at']).to be nil
    notification_id = r.body[0]['id']

    r = @client.put("notifications/#{notification_id}/read", {
      read: nil
    })
    expect(r.status).to eq 400

    r = @client.put("notifications/#{notification_id}/read", {
      read: true
    })
    expect(r.status).to eq 200

    r = @client.get('notifications', {
      'order'       => 'timestamp',
      'direction'   => 'asc',
      'offset'      => 0,
      'limit'       => 10,
      'backtest_id' => 'rmt'
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 3
    expect(r.body[0]['id']).to eq notification_id
    expect(r.body[0]['read_at']).not_to be nil
  end

  it 'PUT /notifications/read で未読通知をまとめて既読にできる' do
    r = @client.get('notifications/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 6
    expect(r.body['not_read']).to be 3

    r = @client.put('notifications/read', {
      read: nil
    })
    expect(r.status).to eq 400

    r = @client.put('notifications/read', {
      'read'        => true,
      'backtest_id' => @test._id.to_s
    })
    expect(r.status).to eq 204

    r = @client.get('notifications/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 6
    expect(r.body['not_read']).to be 1

    r = @client.put('notifications/read', {
      'read'        => true
    })
    expect(r.status).to eq 204

    r = @client.get('notifications/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 6
    expect(r.body['not_read']).to be 0
  end

  def register_notifications
    container    = Jiji::Test::TestContainerFactory.instance.new_container
    data_builder = Jiji::Test::DataBuilder.new

    backtest_repository = container.lookup(:backtest_repository)
    @agent_registry = container.lookup(:agent_registry)

    @agent_registry.add_source('aaa', '',
      :agent, data_builder.new_agent_body(1))
    @test = data_builder.register_backtest(1, backtest_repository)

    setting = data_builder.register_agent_setting
    setting.backtest = @test
    setting.save
    rmt_setting = data_builder.register_agent_setting

    register_notification(rmt_setting)
    register_notification(setting, @test._id)
  end

  def register_notification(agent_setting, backtest_id = nil)
    Jiji::Model::Notification::Notification.create(agent_setting.id,
      Time.at(100), backtest_id, 'message', [],
      'ノート', { chart: { pair: :EURJPY } }).save
    Jiji::Model::Notification::Notification.create(agent_setting.id,
      Time.at(200), backtest_id, 'message2', []).read(Time.at(500))
    Jiji::Model::Notification::Notification.create(agent_setting.id,
      Time.at(300), backtest_id, 'message3', []).save
  end
end
