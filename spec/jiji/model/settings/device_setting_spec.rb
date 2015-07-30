# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/settings/security_setting'

describe Jiji::Model::Settings::DeviceSetting do
  include_context 'use data_builder'
  include_context 'use container'
  let(:repository) { container.lookup(:setting_repository) }

  before(:example) do
    @setting    = repository.device_setting
  end

  it '設定がない場合、初期値を返す' do
    expect(@setting.devices.length).to be 0
  end

  it '設定を永続化できる' do
    @setting.register('foo　ああ', :gcm, 'abc', 'def')
    @setting.register('foo　あい', :apns, 'abx', 'dex')

    expect(@setting.devices.length).to be 2
    expect(@setting.devices['foo　ああ'][:device_token]).to eq 'abc'
    expect(@setting.devices['foo　ああ'][:target_arn]).to eq 'def'
    expect(@setting.devices['foo　ああ'][:type]).to eq :gcm
    expect(@setting.devices['foo　あい'][:device_token]).to eq 'abx'
    expect(@setting.devices['foo　あい'][:target_arn]).to eq 'dex'
    expect(@setting.devices['foo　あい'][:type]).to eq :apns

    @setting.save

    expect(@setting.devices.length).to be 2
    expect(@setting.devices['foo　ああ'][:device_token]).to eq 'abc'
    expect(@setting.devices['foo　ああ'][:target_arn]).to eq 'def'
    expect(@setting.devices['foo　ああ'][:type]).to eq :gcm
    expect(@setting.devices['foo　あい'][:device_token]).to eq 'abx'
    expect(@setting.devices['foo　あい'][:target_arn]).to eq 'dex'
    expect(@setting.devices['foo　あい'][:type]).to eq :apns

    recreate_setting
    expect(@setting.devices['foo　ああ'][:device_token]).to eq 'abc'
    expect(@setting.devices['foo　ああ'][:target_arn]).to eq 'def'
    expect(@setting.devices['foo　ああ'][:type]).to eq :gcm
    expect(@setting.devices['foo　あい'][:device_token]).to eq 'abx'
    expect(@setting.devices['foo　あい'][:target_arn]).to eq 'dex'
    expect(@setting.devices['foo　あい'][:type]).to eq :apns
  end

  def recreate_setting
    @setting    = repository.device_setting
  end
end
