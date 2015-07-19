# coding: utf-8

require 'client'

describe '通知取得' do
  before(:context) do
    register_notifications
  end

  after(:context) do
    @agent_registry.remove_source('aaa')
  end

  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /notifications/rmt で取得数を指定してリアルトレードの通知を取得できる' do
    r = @client.get('notifications/rmt',  {
      'order'     => 'timestamp',
      'direction' => 'desc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    notification = r.body[0]
    expect(notification['backtest_id']).to eq nil
    expect(notification['agent_id']).to eq 'a'
    expect(notification['agent_name']).to eq 'test1'
    expect(notification['message']).to eq 'message'
    expect(notification['icon']).to eq 'icon'
    expect(notification['actions']).to eq []
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(100)
    expect(notification['read_at']).to be nil

    r = @client.get('notifications/rmt',  {
      'order'     => 'timestamp',
      'direction' => 'asc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    notification = r.body[0]
    expect(notification['backtest_id']).to eq nil
    expect(notification['agent_id']).to eq 'a'
    expect(notification['agent_name']).to eq 'test1'
    expect(notification['message']).to eq 'message2'
    expect(notification['icon']).to eq 'icon'
    expect(notification['actions']).to eq []
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(200)
    expect(Time.iso8601(notification['read_at'])).to eq Time.at(500)

    r = @client.get('notifications/rmt',  {
      'order'     => 'timestamp',
      'direction' => 'desc',
      'offset'    => 0,
      'limit'     => 1
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    notification = r.body[0]
    expect(notification['backtest_id']).to eq nil
    expect(notification['agent_id']).to eq 'a'
    expect(notification['agent_name']).to eq 'test1'
    expect(notification['message']).to eq 'message2'
    expect(notification['icon']).to eq 'icon'
    expect(notification['actions']).to eq []
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(200)
    expect(Time.iso8601(notification['read_at'])).to eq Time.at(500)
  end

  it 'GET /notifications/rmt/count でリアルトレードの通知数を取得できる' do
    r = @client.get('notifications/rmt/count')
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
  end

  it 'GET /notifications/:backtest_id で取得数を指定してバックテストの通知を取得できる' do
    r = @client.get("notifications/#{@test._id}",  {
      'order'     => 'timestamp',
      'direction' => 'desc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    notification = r.body[0]
    expect(notification['backtest_id']).to eq @test.id.to_s
    expect(notification['agent_id']).to eq 'a'
    expect(notification['agent_name']).to eq 'test1'
    expect(notification['message']).to eq 'message'
    expect(notification['icon']).to eq 'icon'
    expect(notification['actions']).to eq []
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(100)
    expect(notification['read_at']).to be nil

    r = @client.get("notifications/#{@test._id}",  {
      'order'     => 'timestamp',
      'direction' => 'asc',
      'offset'    => 1,
      'limit'     => 10
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    notification = r.body[0]
    expect(notification['backtest_id']).to eq @test.id.to_s
    expect(notification['agent_id']).to eq 'a'
    expect(notification['agent_name']).to eq 'test1'
    expect(notification['message']).to eq 'message2'
    expect(notification['icon']).to eq 'icon'
    expect(notification['actions']).to eq []
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(200)
    expect(Time.iso8601(notification['read_at'])).to eq Time.at(500)

    r = @client.get("notifications/#{@test._id}",  {
      'order'     => 'timestamp',
      'direction' => 'desc',
      'offset'    => 0,
      'limit'     => 1
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    notification = r.body[0]
    expect(notification['backtest_id']).to eq @test.id.to_s
    expect(notification['agent_id']).to eq 'a'
    expect(notification['agent_name']).to eq 'test1'
    expect(notification['message']).to eq 'message2'
    expect(notification['icon']).to eq 'icon'
    expect(notification['actions']).to eq []
    expect(Time.iso8601(notification['timestamp'])).to eq Time.at(200)
    expect(Time.iso8601(notification['read_at'])).to eq Time.at(500)
  end

  it 'GET /notifications/:backtest_id/count でバックテストの通知数を取得できる' do
    r = @client.get("notifications/#{@test._id}/count")
    expect(r.status).to eq 200
    expect(r.body['count']).to be 2
  end

  def register_notifications
    container    = Jiji::Test::TestContainerFactory.instance.new_container
    data_builder = Jiji::Test::DataBuilder.new

    backtest_repository = container.lookup(:backtest_repository)
    @agent_registry      = container.lookup(:agent_registry)

    @agent_registry.add_source('aaa', '',
      :agent, data_builder.new_agent_body(1))
    @test = data_builder.register_backtest(1, backtest_repository)

    register_notification
    register_notification(@test._id)
  end

  def register_notification(backtest_id = nil)
    Jiji::Model::Notification::Notification.create('a', 'test1', Time.at(100),
      backtest_id, 'message', 'icon',  []).save
    Jiji::Model::Notification::Notification.create('a', 'test1', Time.at(200),
      backtest_id, 'message2', 'icon', []).read(Time.at(500))
  end
end
