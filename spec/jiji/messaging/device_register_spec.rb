# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Messaging::DeviceRegister do
  include_context 'use data_builder'
  include_context 'use container'

  let(:register) { container.lookup(:device_register) }
  let(:repository) { container.lookup(:setting_repository) }

  it 'デバイスを登録できる' do
    register.register({
      type:         'gcm',
      uuid:         '7005121694c81ad5',
      model:        'FJL22',
      platform:     'Android',
      version:      '4.2.2',
      device_token: 'test-token',
      server_url:   'http://localhost:3000'
    })

    devices = Jiji::Messaging::Device.all.map { |d| d }
    expect(devices.length).to eq 1

    device = devices[0]
    expect(device.uuid).to eq '7005121694c81ad5'
    expect(device.type).to eq :gcm
    expect(device.model).to eq 'FJL22'
    expect(device.platform).to eq 'Android'
    expect(device.version).to eq '4.2.2'
    expect(device.device_token).to eq 'test-token'
    expect(device.target_arn).not_to be nil
    expect(device.server_url).to eq 'http://localhost:3000'
  end

  it 'デバイスを更新できる' do
    register.register({
      type:         'gcm',
      uuid:         '7005121694c81ad5',
      model:        'FJL22',
      platform:     'Android',
      version:      '4.2.2',
      device_token: 'test-token',
      server_url:   'http://localhost:3000'
    })

    register.register({
      type:         'gcm',
      uuid:         '7005121694c81ad5',
      model:        'FJL23',
      platform:     'Android',
      version:      '4.2.3',
      device_token: 'test-token2',
      server_url:   'http://localhost:3001'
    })

    devices = Jiji::Messaging::Device.all.map { |d| d }
    expect(devices.length).to eq 1

    device = devices[0]
    expect(device.uuid).to eq '7005121694c81ad5'
    expect(device.type).to eq :gcm
    expect(device.model).to eq 'FJL23'
    expect(device.platform).to eq 'Android'
    expect(device.version).to eq '4.2.3'
    expect(device.device_token).to eq 'test-token2'
    expect(device.target_arn).not_to be nil
    expect(device.server_url).to eq 'http://localhost:3001'
  end
end
