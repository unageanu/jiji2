# coding: utf-8

require 'client'

describe '証券会社の設定' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /settings/securities/available-securities' \
     + 'で利用可能な証券会社が取得できる' do
    r = @client.get('/settings/securities/available-securities')
    expect(r.status).to eq 200
    expect(r.body.length).to be >= 0
    r.body.each do |securities|
      expect(securities['securities_id']).not_to be nil
      expect(securities['name']).not_to be nil
    end
  end

  it 'GET /settings/securities/available-securities/$id/' \
    + 'configuration_definitions で証券会社の設定値が取得できる' do
    r = @client.get('/settings/securities/available-securities/' \
        + 'MOCK/configuration-definitions')
    expect(r.status).to eq 200
    expect(r.body).to eq [
      { 'key' => 'a', 'description' => 'aaa' },
      { 'key' => 'b', 'description' => 'bbb' }
    ]
  end

  it 'アクティブな証券会社を設定できる' do
    r = @client.get('/settings/securities/available-securities/' \
      + 'MOCK/configurations')
    expect(r.status).to eq 200
    expect(r.body).to eq({})

    r = @client.get('/settings/securities/available-securities/' \
      + 'MOCK2/configurations')
    expect(r.status).to eq 200
    expect(r.body).to eq({})

    r = @client.get('/settings/securities/active-securities/id')
    expect(r.status).to eq 404

    r = @client.put('/settings/securities/active-securities', {
        'securities_id' => 'MOCK',
        'configurations' => { 'a' => 'aa', 'b' => 'bb' }
      })
    expect(r.status).to eq 204

    r = @client.get('/settings/securities/active-securities/id')
    expect(r.status).to eq 200
    expect(r.body).to eq({ 'securities_id' => 'MOCK' })

    r = @client.get('/settings/securities/available-securities/' \
      + 'MOCK/configurations')
    expect(r.status).to eq 200
    expect(r.body).to eq({ 'a' => 'aa', 'b' => 'bb' })

    r = @client.put('/settings/securities/active-securities', {
        'securities_id' => 'MOCK2',
        'configurations' => { 'a' => 'aa', 'x' => 'cc' }
      })
    expect(r.status).to eq 204

    r = @client.get('/settings/securities/active-securities/id')
    expect(r.status).to eq 200
    expect(r.body).to eq({ 'securities_id' => 'MOCK2' })

    r = @client.get('/settings/securities/available-securities/' \
      + 'MOCK2/configurations')
    expect(r.status).to eq 200
    expect(r.body).to eq({ 'a' => 'aa', 'x' => 'cc' })

    r = @client.get('/settings/securities/available-securities/' \
      + 'MOCK/configurations')
    expect(r.status).to eq 200
    expect(r.body).to eq({ 'a' => 'aa', 'b' => 'bb' })
  end
end
