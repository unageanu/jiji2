# coding: utf-8

require 'client'

describe 'レート取得' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /rates/range で保持しているレートの範囲を取得できる' do
    sleep 6 # レート取得が走るのを待つ

    r = @client.get('/rates/range')
    expect(r.status).to eq 200
    expect(r.body['start']).not_to be nil
    expect(r.body['end']).not_to be nil

    first = r.body

    sleep 6
    r = @client.get('/rates/range')
    expect(r.status).to eq 200
    expect(r.body['start']).to eq first['start']
    expect(r.body['end']).not_to eq first['end'] # 次のレートが取得されている
  end

  it 'GET /rates/pairs で通貨ペアの一覧を取得できる' do
    r = @client.get('/rates/pairs')
    expect(r.status).to eq 200
    expect(r.body).to eq([
      { 'pair_id' => 0, 'name' => 'EURJPY' },
      { 'pair_id' => 1, 'name' => 'EURUSD' },
      { 'pair_id' => 2, 'name' => 'USDJPY' }
    ])
  end

  it 'GET /rates/$pair_name/$interval でレートを取得できる' do
    r = @client.get('/rates/range')
    start_time = Time.iso8601(r.body['start'])
    end_time   = Time.iso8601(r.body['end'])

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
      'start' => (start_time - 60 * 2).iso8601,
      'end'   => (start_time - 60 * 1).iso8601
    })
    expect(r.status).to eq 400

    r = @client.get('/rates/EURJPY/one_minute', {
      'start' => (end_time + 60 * 2).iso8601,
      'end'   => (end_time + 60 * 3).iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 0

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
