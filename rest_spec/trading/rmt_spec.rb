# frozen_string_literal: true

require 'client'

describe 'リアルトレード' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  after(:example) do
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
      agent_class: 'TestAgent1@テスト1',
      agent_name:  'テスト1',
      properties:  { 'a' => 200, 'b' => 'bb' }
    }, {
      agent_class: 'TestAgent1@テスト1',
      agent_name:  'テスト2',
      properties:  {}
    }])
    expect(r.status).to eq 200
    expect(r.body.length).to eq 2

    r.body.each do |setting|
      expect(setting['id']).not_to be nil
      expect(setting['agent_class']).not_to be nil
      expect(setting['name']).not_to be nil
    end

    agents = [{
      id:          r.body[0]['id'],
      agent_name:  r.body[0]['name'],
      agent_class: r.body[0]['agent_class'],
      properties:  r.body[0]['properties']
    }]
    agents << {
      agent_class: 'TestAgent1@テスト1',
      agent_name:  'テスト3'
    }
    r = @client.put('/rmt/agents', agents)
    expect(r.status).to eq 200
    expect(r.body.length).to eq 2

    r.body.each do |setting|
      expect(setting['id']).not_to be nil
      expect(setting['agent_class']).not_to be nil
      expect(setting['name']).not_to be nil
    end
  end

  it 'GET /rmt/agents でエージェント設定を取得できる' do
    r = @client.get('/rmt/agents')
    expect(r.status).to eq 200
    expect(r.body.length).to eq 2

    r.body.each do |setting|
      expect(setting['id']).not_to be nil
      expect(setting['agent_class']).not_to be nil
      expect(setting['name']).not_to be nil
    end
  end
end
