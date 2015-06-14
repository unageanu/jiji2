# coding: utf-8

require 'client'

describe 'リアルトレード' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /rmt/account でアカウント情報を取得できる' do
    r = @client.get('/rmt/account')
    expect(r.status).to eq 200

    expect(r.body['balance']).to be >= 0
    expect(r.body['margin_rate']).to be >= 0
    expect(r.body['margin_used']).to be >= 0
    expect(r.body['profit_or_loss']).to be >= 0
  end
end
