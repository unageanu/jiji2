# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Messaging::PushNotifier do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container     = Jiji::Test::TestContainerFactory.instance.new_container
    @register      = @container.lookup(:device_register)
    @push_notifier = @container.lookup(:push_notifier)
    @repository    = @container.lookup(:setting_repository)
  end

  after(:example) do
    @data_builder.clean
  end

  it 'デバイスを登録できる' do
    @register.register('device1', 'test-token')
    @register.register('device2', 'test-token')

    setting = @repository.device_setting
    expect(setting.devices.length).to eq 2

    message_ids = @push_notifier.notify('テスト', '{test:"test"}')
    expect(message_ids).to eq %w(message_id message_id)
  end
end
