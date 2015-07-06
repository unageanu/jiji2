# coding: utf-8

require 'client'
require 'uri'

describe 'バックテスト' do
  before(:example) do
    @client = Jiji::Client.instance
    @data_builder = Jiji::Test::DataBuilder.new
  end

  it 'POST /backtests でバックテストを登録できる' do
    r = @client.post('backtests', {
      'name'          => 'テスト',
      'start_time'    => Time.utc(2015, 6, 2),
      'end_time'      => Time.utc(2015, 6, 2, 0, 10, 0),
      'memo'          => 'メモ',
      'pair_names'    => [:EURJPY, :EURUSD],
      'balance'       => 1_000_000,
      'agent_setting' => [
        {
          agent_class: 'TestAgent1@テスト1',
          agent_name:  'テスト1',
          properties:  { 'a' => 1, 'b' => 'bb' }
        }
      ]
    })
    expect(r.status).to eq 201

    expect(r.body['name']).to eq 'テスト'
    expect(r.body['id']).not_to be nil
    expect(r.body['created_at']).not_to be nil
  end

  it 'GET /backtests でバックテストの一覧を取得できる' do
    r = @client.get('backtests')
    expect(r.status).to eq 200

    expect(r.body.length).to eq 1
    r.body.each do |b|
      expect(b['id']).not_to be nil
      expect(b['name']).not_to be nil
      expect(b['created_at']).not_to be nil
    end
  end

  it 'GET /backtests?ids=[] で任意のバックテストの一覧を取得できる' do
    r = @client.get('backtests')
    r = @client.get('backtests', { 'ids': "#{r.body[0]['id']}" })
    expect(r.status).to eq 200

    expect(r.body.length).to be 1
    r.body.each do |b|
      expect(b['id']).not_to be nil
      expect(b['name']).not_to be nil
      expect(b['created_at']).not_to be nil
    end
  end

  it 'GET /backtests/:id/account でバックテストの口座情報を取得できる' do
    r = @client.get('backtests')
    id = r.body.find { |b| b['name'] == 'テスト' }['id']

    r = @client.get("backtests/#{id}/account")
    expect(r.status).to eq 200
    expect(r.body['balance']).to be >= 0
    expect(r.body['margin_rate']).to be >= 0
    expect(r.body['margin_used']).to be >= 0
    expect(r.body['profit_or_loss']).to be >= 0
  end

  it 'DELETE /backtests/:id でバックテストを削除できる' do
    r = @client.get('backtests')
    id = r.body.find { |b| b['name'] == 'テスト' }['id']

    r = @client.delete("backtests/#{id}")
    expect(r.status).to eq 204

    r = @client.get('backtests')
    expect(r.status).to eq 200
    expect(r.body).to eq []
  end
end
