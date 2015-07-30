# coding: utf-8

require 'client'

describe 'リアルトレード' do
  before(:example) do
    register_agent
    @client = Jiji::Client.instance
  end

  after(:example) do
    @agent_registry.remove_source('aaa')
  end

  it 'GET /rmt/account でアカウント情報を取得できる' do
    r = @client.get('/rmt/account')
    expect(r.status).to eq 200

    expect(r.body['balance']).to be >= 0
    expect(r.body['margin_rate']).to be >= 0
    expect(r.body['margin_used']).to be >= 0
    expect(r.body['profit_or_loss']).to be >= 0
    expect(r.body['balance_of_yesterday']).to be nil
  end

  it 'PUT /rmt/agents でエージェントの設定を作成/更新できる' do
    r = @client.put('/rmt/agents', [{
      agent_class: 'TestAgent1@aaa',
      agent_name:  'テスト1',
      properties:  { 'a' => 200, 'b' => 'bb' }
    }, {
      agent_class: 'TestAgent1@aaa',
      agent_name:  'テスト2',
      properties:  {}
    }])
    expect(r.status).to eq 200
    expect(r.body.length).to eq 2

    r.body.each do |setting|
      expect(setting['uuid']).not_to be nil
      expect(setting['agent_class']).not_to be nil
      expect(setting['agent_name']).not_to be nil
    end

    agents = r.body[0, 1]
    agents << {
      agent_class: 'TestAgent1@aaa',
      agent_name:  'テスト3'
    }
    r = @client.put('/rmt/agents', agents)
    expect(r.status).to eq 200
    expect(r.body.length).to eq 2

    r.body.each do |setting|
      expect(setting['uuid']).not_to be nil
      expect(setting['agent_class']).not_to be nil
      expect(setting['agent_name']).not_to be nil
    end
  end

  it 'GET /rmt/agents でエージェント設定を取得できる' do
    r = @client.get('/rmt/agents')
    expect(r.status).to eq 200
    expect(r.body.length).to eq 2

    r.body.each do |setting|
      expect(setting['uuid']).not_to be nil
      expect(setting['agent_class']).not_to be nil
      expect(setting['agent_name']).not_to be nil
    end
  end

  def register_agent
    container    = Jiji::Test::TestContainerFactory.instance.new_container
    data_builder = Jiji::Test::DataBuilder.new

    @agent_registry      = container.lookup(:agent_registry)

    @agent_registry.add_source('aaa', '',
      :agent, data_builder.new_agent_body(1))
  end
end
