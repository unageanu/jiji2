# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Settings::RMTSetting do
  include_context 'use data_builder'
  include_context 'use container'
  let(:repository) { container.lookup(:setting_repository) }

  before(:example) do
    @setting    = repository.rmt_setting
  end

  it '設定がない場合、初期値を返す' do
    expect(@setting.agent_setting).to eq []
    expect(@setting.is_trade_enabled).to eq true
  end

  it '設定を永続化できる' do
    @setting.agent_setting = [
      { 'name' => 'TestAgent1@aaa', 'properties' => { 'a' => 1, 'b' => 'bb' } },
      { 'name' => 'TestAgent1@aaa', 'properties' => {} },
      { 'name' => 'TestAgent2@bbb' }
    ]
    @setting.is_trade_enabled = false

    expect(@setting.agent_setting).to eq [
      { 'name' => 'TestAgent1@aaa', 'properties' => { 'a' => 1, 'b' => 'bb' } },
      { 'name' => 'TestAgent1@aaa', 'properties' => {} },
      { 'name' => 'TestAgent2@bbb' }
    ]
    expect(@setting.is_trade_enabled).to eq false

    @setting.save

    expect(@setting.agent_setting).to eq [
      { 'name' => 'TestAgent1@aaa', 'properties' => { 'a' => 1, 'b' => 'bb' } },
      { 'name' => 'TestAgent1@aaa', 'properties' => {} },
      { 'name' => 'TestAgent2@bbb' }
    ]
    expect(@setting.is_trade_enabled).to eq false

    recreate_setting
    expect(@setting.agent_setting).to eq [
      { 'name' => 'TestAgent1@aaa', 'properties' => { 'a' => 1, 'b' => 'bb' } },
      { 'name' => 'TestAgent1@aaa', 'properties' => {} },
      { 'name' => 'TestAgent2@bbb' }
    ]
    expect(@setting.is_trade_enabled).to eq false
  end

  def recreate_setting
    @setting    = repository.rmt_setting
  end
end
