# coding: utf-8

require 'client'
require 'uri'

describe 'エージェント' do
  before(:example) do
    @client = Jiji::Client.instance
    @data_builder = Jiji::Test::DataBuilder.new
  end

  it 'GET /agents/sources でエージェント一覧を取得できる' do
    r = @client.get('agents/sources')
    expect(r.status).to eq 200

    expect(r.body.length).to eq 3
  end

  it 'POST /agents/sources でエージェントを登録できる' do
    r = @client.post('agents/sources', {
      name: 'テスト1',
      memo: 'メモ1',
      type: :agent,
      body: @data_builder.new_agent_body(1)
    })
    expect(r.status).to eq 201

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'テスト1'

    r = @client.post('/agents/sources', {
      name: 'テスト/テスト2',
      memo: 'メモ2',
      type: :agent,
      body: 'class Foo;'
    })
    expect(r.status).to eq 201

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).not_to be nil
    expect(r.body['status']).to eq 'error'
    expect(r.body['name']).to eq 'テスト/テスト2'

    r = @client.post('/agents/sources', {
      name: 'テスト/テスト4',
      memo: 'メモ4',
      type: :agent
    })
    expect(r.status).to eq 201

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'empty'
    expect(r.body['name']).to eq 'テスト/テスト4'
  end

  it 'GET /agents/sources でエージェントファイルの一覧を取得できる' do
    r = @client.get('agents/sources')
    expect(r.status).to eq 200

    expect(r.body.length).to be 6
    r.body.each do |a|
      expect(a['id']).not_to be nil
      expect(a['status']).not_to be nil
      expect(a['body']).to be nil
    end
  end

  it 'GET /agents/sources/:id でエージェントを取得できる' do
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'テスト/テスト2' }['id']

    r = @client.get("agents/sources/#{id}")
    expect(r.status).to eq 200

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).not_to be nil
    expect(r.body['status']).to eq 'error'
    expect(r.body['name']).to eq 'テスト/テスト2'
    expect(r.body['body']).to eq 'class Foo;'
  end

  it 'PUT /agents/sources/:id でエージェントを更新できる' do
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'テスト/テスト2' }['id']

    r = @client.put("agents/sources/#{id}", {
      body: @data_builder.new_agent_body(2)
    })
    expect(r.status).to eq 200
    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'テスト/テスト2'
    expect(r.body['body']).to eq @data_builder.new_agent_body(2)

    r = @client.get("agents/sources/#{id}")
    expect(r.status).to eq 200

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'テスト/テスト2'
    expect(r.body['body']).to eq @data_builder.new_agent_body(2)

    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'テスト/テスト4' }['id']
    r = @client.put("agents/sources/#{id}", {
      body: @data_builder.new_agent_body(4)
    })
    expect(r.status).to eq 200
  end

  it 'PUT /agents/sources/:id でエージェントをリネームできる' do
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'テスト/テスト2' }['id']

    r = @client.put("agents/sources/#{id}", {
      name: 'テスト/テスト3',
      body: @data_builder.new_agent_body(3)
    })
    expect(r.status).to eq 200

    r = @client.get("agents/sources/#{id}")
    expect(r.status).to eq 200

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'テスト/テスト3'
    expect(r.body['body']).to eq @data_builder.new_agent_body(3)
  end

  it 'POST,PUTは、同名のファイルがすでにある場合エラーになる' do
    r = @client.post('agents/sources', {
      name: 'テスト/テスト3',
      memo: 'メモ1',
      type: :agent,
      body: @data_builder.new_agent_body(1)
    })
    expect(r.status).to eq 400

    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'テスト1' }['id']

    r = @client.put("agents/sources/#{id}", {
      name: 'テスト/テスト3',
      body: @data_builder.new_agent_body(3)
    })
    expect(r.status).to eq 400
  end

  it 'DELETE /agents/sources/:id でエージェントを削除できる' do
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'テスト/テスト3' }['id']
    r = @client.delete("agents/sources/#{id}")
    expect(r.status).to eq 204

    r = @client.get("agents/sources/#{id}")
    expect(r.status).to eq 404
  end

  it 'GET /agents/classes でエージェントクラスの一覧を取得できる' do
    r = @client.get('agents/classes')
    expect(r.status).to eq 200
    expect(r.body.sort_by { |i| i['name'] }).to eq([{
      'name' => 'MovingAverageAgent@moving_average_agent.rb',
      'description' => "移動平均を使うエージェントです。\n" \
       + " -ゴールデンクロスで買い&売り建て玉をコミット。\n" \
       + " -デッドクロスで売り&買い建て玉をコミット。\n",
      'properties' => [
        { 'id' => 'short', 'name' => '短期移動平均線', 'default' => 25 },
        { 'id' => 'long',  'name' => '長期移動平均線', 'default' => 75 }
      ]
    }, {
      'name' => 'TestAgent1@テスト1',
      'description' => 'description1',
      'properties' => [
        { 'id' => 'a', 'name' => 'aa', 'default' => 1 },
        { 'id' => 'b', 'name' => 'bb', 'default' => 1 }
      ]
    }, {
      'name' => 'TestAgent4@テスト/テスト4',
      'description' => 'description4',
      'properties' => [
        { 'id' => 'a', 'name' => 'aa', 'default' => 1 },
        { 'id' => 'b', 'name' => 'bb', 'default' => 4 }
      ]
    }])
  end

  it 'GET /agents/available-languages' do
    r = @client.get('agents/available-languages')
    expect(r.status).to eq 200

    expect(r.body).to eq %w(python ruby)
  end
end
