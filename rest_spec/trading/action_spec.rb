# coding: utf-8

require 'client'

describe 'アクションの実行' do
  before(:example) do
    @client = Jiji::Client.instance
    register_agent
  end

  after(:example) do
    Jiji::Model::Notification::Notification.drop
    unregister_agent
  end

  it 'POST actions でアクションを実行できる' do
    r = @client.put('/rmt/agents', [{
      agent_class: 'TestAgent1@action_test',
      agent_name:  'テスト1'
    }])
    expect(r.status).to eq 200

    r = @client.get('notifications',  {
      'backtest_id' => 'rmt'
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1
    notification = r.body[0]

    r = @client.post('/actions', {
      agent_id: notification['agent']['id'],
      action:   'aaa'
    })
    expect(r.status).to eq 200
    expect(r.body['message']).to eq 'OK aaa'

    r = @client.get('notifications',  {
      'backtest_id' => 'rmt'
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 2

    r = @client.post('/actions', {
      agent_id: notification['agent']['id'],
      action:   'error'
    })
    expect(r.status).to eq 400
  end

  def register_agent
    data_builder = Jiji::Test::DataBuilder.new
    r = @client.post('agents/sources', {
      name: 'action_test',
      memo: 'メモ1',
      type: :agent,
      body: data_builder.new_notification_agent_body(1)
    })
    expect(r.status).to eq 201
  end

  def unregister_agent
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'action_test' }['id']
    r = @client.delete("agents/sources/#{id}")
    expect(r.status).to eq 204
  end
end
