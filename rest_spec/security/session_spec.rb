# coding: utf-8

require 'client'

describe '初期化' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  context '初期化後' do
    it 'DELETE /sessions でログアウトできる' do
      r = @client.post('/authenticator', password: 'test')
      expect(r.status).to eq 201

      token = r.body['token']
      @client.token = token

      r = @client.get('/settings/securities/available-securities')
      expect(r.status).to eq 200

      # ログアウト
      r = @client.delete('/sessions')
      expect(r.status).to eq 204

      r = @client.get('/settings/securities/available-securities')
      expect(r.status).to eq 401

      # 再ログインしておく
      r = @client.post('/authenticator', password: 'test')
      expect(r.status).to eq 201

      token = r.body['token']
      @client.token = token
    end
  end
end
