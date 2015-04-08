# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Messaging::DeviceRegister do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container  = Jiji::Test::TestContainerFactory.instance.new_container
    @register   = @container.lookup(:device_register)
    @repository = @container.lookup(:setting_repository)
  end

  after(:example) do
    @data_builder.clean
  end

  it 'デバイスを登録できる' do
    @register.register('name', 'test-token')

    setting = @repository.device_setting
    expect(setting.devices.length).to eq 1
    expect(setting.devices['name'][:target_arn]).to eq 'target_arn'
    expect(setting.devices['name'][:type]).to eq :gcm
    expect(setting.devices['name'][:device_token]).to eq 'test-token'
  end
end
