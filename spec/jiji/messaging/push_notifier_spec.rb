# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Messaging::PushNotifier do
  include_context 'use data_builder'
  include_context 'use container'

  let(:device_register) { container.lookup(:device_register) }
  let(:push_notifier) { container.lookup(:push_notifier) }
  let(:repository) { container.lookup(:setting_repository) }

  it 'デバイスを登録できる' do
    device_register.register({
      type:         'gcm',
      uuid:         '7005121694c81ad5',
      model:        'FJL22',
      platform:     'Android',
      version:      '4.2.2',
      device_token: 'test-token'
    })
    device_register.register({
      type:         'gcm',
      uuid:         '7005121694c81ad6',
      model:        'FJL22',
      platform:     'Android',
      version:      '4.2.2',
      device_token: 'test-token2'
    })

    devices = Jiji::Messaging::Device.all.map {|d| d}
    expect(devices.length).to eq 2

    message_ids = push_notifier.notify('テスト', '{test:"test"}')
    expect(message_ids).to eq %w(message_id message_id)
  end
end
