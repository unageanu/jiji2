# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Agents::AgentSetting do
  include_context 'use backtests'

  describe '#get_or_create' do
    it 'idに対応するAgentSettingを取得できる' do
      setting = register_setting

      loaded = Jiji::Model::Agents::AgentSetting.get_or_create(setting.id)
      expect(loaded.id).to eq setting.id
      expect(loaded.backtest_id).to eq nil
      expect(loaded.name).to eq 'test1'
      expect(loaded.agent_class).to eq 'testClass1'
      expect(loaded.icon_id).to eq setting.icon_id
      expect(loaded.state).to eq({
        'string'  => '文字列',
        'number'  => 1.0,
        'boolean' => false
      })
      expect(loaded.properties).to eq({
        'string'  => '文字列',
        'number'  => 2.0,
        'boolean' => true
      })
      expect(loaded.active).to eq false
    end

    it 'idに対応するAgentSettingがなければ新規に作成される' do
      loaded = Jiji::Model::Agents::AgentSetting
               .get_or_create(BSON::ObjectId.from_time(Time.new))
      expect(loaded.id).not_to be nil
      expect(loaded.backtest_id).to eq nil
      expect(loaded.name).to be nil
      expect(loaded.agent_class).to eq nil
      expect(loaded.icon_id).to eq nil
      expect(loaded.state).to eq nil
      expect(loaded.properties).to eq nil
      expect(loaded.active).to eq true

      loaded = Jiji::Model::Agents::AgentSetting.get_or_create(nil)
      expect(loaded.id).not_to be nil
      expect(loaded.backtest_id).to eq nil
      expect(loaded.name).to be nil
      expect(loaded.agent_class).to eq nil
      expect(loaded.icon_id).to eq nil
      expect(loaded.state).to eq nil
      expect(loaded.properties).to eq nil
      expect(loaded.active).to eq true
    end
  end

  describe '#get_or_create_from_hash' do
    it 'ハッシュから作成できる' do
      icon_id = BSON::ObjectId.from_time(Time.new)
      loaded = Jiji::Model::Agents::AgentSetting
               .get_or_create_from_hash({
          agent_class: 'testClass2',
          agent_name:  'test2',
          icon_id:     icon_id.to_s,
          properties:  {
            'string'  => '文字列',
            'number'  => 1.0,
            'boolean' => true
          }
        }, backtests[0].id)
      expect(loaded.id).not_to be nil
      expect(loaded.backtest_id).to eq backtests[0].id
      expect(loaded.name).to eq 'test2'
      expect(loaded.agent_class).to eq 'testClass2'
      expect(loaded.icon_id).to eq icon_id
      expect(loaded.state).to eq(nil)
      expect(loaded.properties).to eq({
        'string'  => '文字列',
        'number'  => 1.0,
        'boolean' => true
      })
      expect(loaded.active).to eq true
    end
    it 'hashにidがあり、対応する設定がある場合、既存の設定が更新され返される' do
      setting = register_setting
      icon_id = BSON::ObjectId.from_time(Time.new)
      loaded = Jiji::Model::Agents::AgentSetting
               .get_or_create_from_hash({
          id:          setting.id.to_s,
          agent_class: 'testClass2',
          agent_name:  'test2',
          icon_id:     icon_id.to_s,
          properties:  {
            'string'  => '文字列',
            'number'  => 1.0,
            'boolean' => true
          }
        }, backtests[1].id)
      expect(loaded.id).to eq setting.id
      expect(loaded.backtest_id).to eq backtests[1].id
      expect(loaded.name).to eq 'test2'
      expect(loaded.agent_class).to eq 'testClass2'
      expect(loaded.icon_id).to eq icon_id
      expect(loaded.state).to eq({
        'string'  => '文字列',
        'number'  => 1.0,
        'boolean' => false
      })
      expect(loaded.properties).to eq({
        'string'  => '文字列',
        'number'  => 1.0,
        'boolean' => true
      })
      expect(loaded.active).to eq false
    end
  end

  describe '#load' do
    before(:example) do
      @settings = [
        register_setting('test1', backtests[0], true),
        register_setting('test2', backtests[0], true),
        register_setting('test3', backtests[1], true),
        register_setting('test4', nil, true),
        register_setting('test5', nil, true)
      ]
    end

    it '登録されたエージェント設定の一覧を取得できる' do
      settings = Jiji::Model::Agents::AgentSetting.load(backtests[0].id)
      expect(settings.length).to eq 3
      expect(settings[0].name).to eq nil
      expect(settings[1].name).to eq 'test1'
      expect(settings[2].name).to eq 'test2'

      settings = Jiji::Model::Agents::AgentSetting.load(backtests[1].id)
      expect(settings.length).to eq 2
      expect(settings[0].name).to eq nil
      expect(settings[1].name).to eq 'test3'

      settings = Jiji::Model::Agents::AgentSetting.load
      expect(settings.length).to be 2
      expect(settings[0].name).to eq 'test4'
      expect(settings[1].name).to eq 'test5'
    end

    it 'active=falseのエージェントは一覧に含まれない' do
      @settings[3].active = false
      @settings[3].save

      settings = Jiji::Model::Agents::AgentSetting.load
      expect(settings.length).to be 1
      expect(settings[0].name).to eq 'test5'
    end
  end

  it 'to_hでハッシュに変換できる' do
    setting = register_setting
    expect(setting.to_h).to eq({
      id:          setting.id,
      name:        'test1',
      icon_id:     setting.icon_id,
      agent_class: 'testClass1',
      properties:  {
        'string'  => '文字列',
        'number'  => 2.0,
        'boolean' => true
      }
    })
  end

  it 'display_infoで表示用の情報を抽出できる' do
    setting = register_setting
    expect(setting.display_info).to eq({
      id:      setting.id,
      name:    'test1',
      icon_id: setting.icon_id
    })
  end

  def register_setting(name = 'test1', backtest = nil, active = false)
    setting = Jiji::Model::Agents::AgentSetting.new
    setting.backtest    = backtest
    setting.name        = name
    setting.agent_class = 'testClass1'
    setting.icon_id     = BSON::ObjectId.from_time(Time.new)
    setting.state = {
      'string'  => '文字列',
      'number'  => 1.0,
      'boolean' => false
    }
    setting.properties = {
      'string'  => '文字列',
      'number'  => 2.0,
      'boolean' => true
    }
    setting.active = active
    setting.save
    setting
  end
end
