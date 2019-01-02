# frozen_string_literal: true

require 'client'

describe '通貨ペアの設定' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /settings/pairs/all　ですべての通貨ペアの一覧を取得できる' do
    r = @client.get('/settings/pairs/all')
    expect(r.status).to eq 200
    expect(r.body).to eq([{
      'name' => 'EURJPY',
      'internal_id' => 'EUR_JPY',
      'pip' => 0.01,
      'max_trade_units' => 10_000_000,
      'precision' => 0.001,
      'margin_rate' => 0.04
    }, {
      'name' => 'EURUSD',
      'internal_id' => 'EUR_USD',
      'pip' => 0.0001,
      'max_trade_units' => 10_000_000,
      'precision' => 1.0e-05,
      'margin_rate' => 0.04
    }, {
      'name' => 'USDJPY',
      'internal_id' => 'USD_JPY',
      'pip' => 0.01,
      'max_trade_units' => 10_000_000,
      'precision' => 0.001,
      'margin_rate' => 0.04
    }])
  end

  it 'GET /settings/pairs　で使用する通貨ペアの一覧を取得できる' do
    r = @client.get('/settings/pairs')
    expect(r.status).to eq 200
    expect(r.body).to eq([{
      'name' => 'EURJPY',
      'internal_id' => 'EUR_JPY',
      'pip' => 0.01,
      'max_trade_units' => 10_000_000,
      'precision' => 0.001,
      'margin_rate' => 0.04
    }, {
      'name' => 'USDJPY',
      'internal_id' => 'USD_JPY',
      'pip' => 0.01,
      'max_trade_units' => 10_000_000,
      'precision' => 0.001,
      'margin_rate' => 0.04
    }])
  end

  it 'PUT /settings/pairs　で使用する通貨ペアを設定できる' do
    r = @client.put('/settings/pairs', [{
     'name' => 'EURUSD',
     'internal_id' => 'EUR_USD',
     'pip' => 0.0001,
     'max_trade_units' => 10_000_000,
     'precision' => 1.0e-05,
     'margin_rate' => 0.04
    }, {
     'name' => 'USDJPY',
     'internal_id' => 'USD_JPY',
     'pip' => 0.01,
     'max_trade_units' => 10_000_000,
     'precision' => 0.001,
     'margin_rate' => 0.04
    }])
    expect(r.status).to eq 204

    r = @client.get('/settings/pairs')
    expect(r.status).to eq 200
    expect(r.body).to eq([{
      'name' => 'EURUSD',
      'internal_id' => 'EUR_USD',
      'pip' => 0.0001,
      'max_trade_units' => 10_000_000,
      'precision' => 1.0e-05,
      'margin_rate' => 0.04
    }, {
      'name' => 'USDJPY',
      'internal_id' => 'USD_JPY',
      'pip' => 0.01,
      'max_trade_units' => 10_000_000,
      'precision' => 0.001,
      'margin_rate' => 0.04
    }])
  end
end
