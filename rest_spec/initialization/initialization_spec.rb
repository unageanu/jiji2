# coding: utf-8

require 'server'
require 'client'

describe '初期化' do
  before(:example) do
    Jiji::Server.instance.setup
    @client = Jiji::Client.instance
  end

  context '初期化前' do
    it 'GET /setting/initialization/initialized がfalseを返す' do
      r = @client.get('/setting/initialization/initialized')
      expect(r.status).to eq 200
      expect(r.body['initialized']).to eq false
    end

    it 'PUT /setting/initialization/password で初期化できる' do
      r = @client.put('/setting/initialization/password', password: 'test')
      expect(r.status).to eq 204
    end
  end

  context '初期化後' do
    it 'GET /setting/initialization/initialized がtrueを返す' do
      r = @client.get('/setting/initialization/initialized')
      expect(r.status).to eq 200
      expect(r.body['initialized']).to eq true
    end

    it 'POST /authenticator で認証できる' do
      r = @client.post('/authenticator', password: 'test')
      expect(r.status).to eq 201

      body = r.body
      expect(body['token'].length).to be >= 0
      @client.token = body['token']
    end
  end

  context '認証後' do
    it 'GET /setting/rmt-broker/available-securities' \
       + 'で利用可能な証券会社が取得できる' do
      r = @client.get('/setting/rmt-broker/available-securities')
      expect(r.status).to eq 200
      expect(r.body.length).to be >= 0
      r.body.each do |securities|
        expect(securities['securities_id']).not_to be nil
        expect(securities['name']).not_to be nil
      end
    end

    it 'GET /setting/rmt-broker/available-securities/$id/' \
      + 'configuration_definitions で証券会社の設定値が取得できる' do
      r = @client.get('/setting/rmt-broker/available-securities/' \
          + 'mock/configuration_definitions')
      expect(r.status).to eq 200
      expect(r.body).to eq [
        { 'key' => 'a', 'description' => 'aaa', 'secure' => true },
        { 'key' => 'b', 'description' => 'bbb', 'secure' => false },
        { 'key' => 'c', 'description' => 'ccc', 'secure' => true }
      ]
    end

    it 'GET/PUT /setting/rmt-broker/available-securities/$id/configurations' \
      + 'で証券会社の設定値を取得/変更できる' do
      r = @client.get('/setting/rmt-broker/available-securities/' \
        + 'mock/configurations')
      expect(r.status).to eq 200
    end
  end
end
