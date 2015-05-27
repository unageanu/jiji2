# coding: utf-8

require 'client'

describe 'レート取得' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /rates/range で保持しているレートの範囲を取得できる' do
    r = @client.get('/rates/range')
    expect(r.status).to eq 200
    expect(r.body['start']).not_to be nil
    expect(r.body['end']).not_to be nil
  end

  it 'GET /rates/pairs で通貨ペアの一覧を取得できる' do
    r = @client.get('/rates/pairs')
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

  it 'GET /rates/$pair_name/$interval でレートを取得できる' do
    r = @client.get('/rates/range')
    start_time = Time.now - 60 * 60 * 24 * 10
    end_time   = Time.now

    %w(EURJPY EURUSD).each do |pair|
      %w(one_minute one_hour one_day).each do |interval|
        r = @client.get("/rates/#{pair}/#{interval}", {
          'start' => (start_time += 1).iso8601,
          'end'   => (end_time += 1).iso8601
        })
        expect(r.status).to eq 200
        expect(r.body.length).to be > 0
      end
    end

    r = @client.get('/rates/EURJPY/one_minute', {
      'start' => (end_time + 60 * 2).iso8601,
      'end'   => (end_time + 60 * 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be > 0

    r = @client.get('/rates/EURJPY/one_minute', {
      'start' => (start_time).iso8601,
      'end'   => (end_time   + 60).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be > 0

    range =  {
      'start' => (start_time).iso8601,
      'end'   => (end_time   + 60).iso8601
    }

    r = @client.get('/rates/UNKNOWN_PAIR/one_minute', range)
    expect(r.status).to eq 404

    r = @client.get('/rates/EURUSD/unknown_interval', range)
    expect(r.status).to eq 404
  end
end
