# frozen_string_literal: true

require 'client'

describe 'デバイスの登録' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'PUT /devices/:uuid でデバイスを登録できる' do
    r = @client.put('/devices/7005121694c81ad5', {
      type:         'gcm',
      model:        'FJL22',
      platform:     'Android',
      version:      '4.2.2',
      device_token: 'test-token',
      server_url:   'http://localhost:3000'
    })
    expect(r.status).to eq 200
    expect(r.body['uuid']).to eq '7005121694c81ad5'
    expect(r.body['model']).to eq 'FJL22'

    r = @client.put('/devices/7005121694c81ad5', {
      type:         'gcm',
      model:        'FJL23',
      platform:     'Android',
      version:      '4.2.3',
      device_token: 'test-token',
      server_url:   'http://localhost:3001'
    })
    expect(r.status).to eq 200
    expect(r.body['uuid']).to eq '7005121694c81ad5'
    expect(r.body['model']).to eq 'FJL23'
  end
end
