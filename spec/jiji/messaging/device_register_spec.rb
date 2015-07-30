# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Messaging::DeviceRegister do
  include_context 'use data_builder'
  include_context 'use container'

  let(:register) { container.lookup(:device_register) }
  let(:repository) { container.lookup(:setting_repository) }

  it 'デバイスを登録できる' do
    register.register('name', 'test-token')

    setting = repository.device_setting
    expect(setting.devices.length).to eq 1
    expect(setting.devices['name'][:target_arn]).to eq 'target_arn'
    expect(setting.devices['name'][:type]).to eq :gcm
    expect(setting.devices['name'][:device_token]).to eq 'test-token'
  end
end
