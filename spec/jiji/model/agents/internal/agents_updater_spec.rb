# coding: utf-8

require 'jiji/test/test_configuration'

require 'securerandom'

describe Jiji::Model::Agents::Internal::AgentsUpdater do
  include_context 'use data_builder'
  include_context 'use container'

  let(:agent_source_repository) { container.lookup(:agent_source_repository) }
  let(:agent_registry) { container.lookup(:agent_registry) }
  let(:mail_composer) { container.lookup(:mail_composer) }
  let(:push_notifier) { container.lookup(:push_notifier) }
  let(:time_source)   { container.lookup(:time_source) }
  let(:logger) { Logger.new(STDOUT) }
  let(:components) do
    {
        broker:        :broker,
        graph_factory: :graph_factory,
        logger:        logger,
        push_notifier: push_notifier,
        mail_composer: mail_composer,
        time_source:   time_source
    }
  end
  let(:agents_builder) do
    Jiji::Model::Agents::Internal::AgentsUpdater.new(
      nil, agent_registry, components)
  end

  before(:example) do
    agent_registry.add_source('aaa', '', :agent, new_body(1))
    agent_registry.add_source('bbb', '', :agent, new_body(2))
  end

  describe '#build' do
    it 'エージェントを作成できる' do
      setting_source = [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     BSON::ObjectId.from_time(Time.new),
          properties:  { a: 100, b: 'bb' }
        }, {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2',
          properties:  {}
        }, {
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents = {}
      agents = agents_builder.update(agents, setting_source)
      expect(agents.length).to be 3

      settings = Jiji::Model::Agents::AgentSetting.load.map { |m| m }
      expect(settings.length).to be 3

      setting1 = settings.find { |a| a.name == 'テスト1' }
      agent1   = agents[setting1.id]
      expect(agent1).not_to be nil
      expect(agent1.properties).to eq({ 'a' => 100, 'b' => 'bb' })
      expect(agent1.broker.agent_id).to eq setting1.id
      expect(agent1.graph_factory).to eq :graph_factory
      expect(agent1.notifier.agent_id).to eq setting1.id
      expect(agent1.logger).to be logger
      expect(agent1.agent_name).to eq 'テスト1'
      expect(setting1.active).to be true
      expect(setting1.name).to eq 'テスト1'
      expect(setting1.agent_class).to eq 'TestAgent1@aaa'
      expect(setting1.icon_id).to eq setting_source[0][:icon_id]
      expect(setting1.properties).to eq({ 'a' => 100, 'b' => 'bb' })

      setting2 = settings.find { |a| a.name == 'テスト2' }
      agent2   = agents[setting2.id]
      expect(agent2).not_to be nil
      expect(agent2.properties).to eq({})
      expect(agent2.broker.agent_id).to eq setting2.id
      expect(agent2.graph_factory).to eq :graph_factory
      expect(agent2.notifier.agent_id).to eq setting2.id
      expect(agent2.logger).to be logger
      expect(agent2.agent_name).to eq 'テスト2'
      expect(setting2.active).to be true
      expect(setting2.name).to eq 'テスト2'
      expect(setting2.agent_class).to eq 'TestAgent1@aaa'
      expect(setting2.icon_id).to eq nil
      expect(setting2.properties).to eq({})

      setting3 = settings.find { |a| a.name.nil? }
      agent3   = agents[setting3.id]
      expect(agent3).not_to be nil
      expect(agent3.properties).to eq({})
      expect(agent3.broker.agent_id).to eq setting3.id
      expect(agent3.graph_factory).to eq :graph_factory
      expect(agent3.notifier.agent_id).to eq setting3.id
      expect(agent3.logger).to be logger
      expect(agent3.agent_name).to eq 'TestAgent2@bbb'
      expect(setting3.active).to be true
      expect(setting3.name).to eq nil
      expect(setting3.agent_class).to eq 'TestAgent2@bbb'
      expect(setting3.icon_id).to eq nil
      expect(setting3.properties).to eq({})
    end

    it 'fail_on_error=trueで エージェントが見つからない場合エラー' do
      agents = {}
      expect do
        agents_builder.update(agents, [
          { agent_class: 'TestAgent2@bbb',    agent_name: '0' },
          { agent_class: 'UnknownAgent1@unknown', properties: {} },
          { agent_class: 'TestAgent2@bbb',    agent_name: '1' }
        ], true)
      end.to raise_exception(Jiji::Errors::NotFoundException)

      settings = Jiji::Model::Agents::AgentSetting.all.map { |m| m }
      expect(settings.empty?).to be true
    end

    it 'エージェントが見つからない場合でもfail_on_error=falseの場合エラーにはならない' do
      agents = {}
      settings = [
        { agent_class: 'UnknownAgent1@aaa', agent_name: '1', properties: {} },
        { agent_class: 'TestAgent2@bbb',    agent_name: '2' }
      ]
      agents = agents_builder.update(agents, settings)

      settings = Jiji::Model::Agents::AgentSetting.all.map { |m| m }

      setting1 = settings.find { |a| a.name == '1' }
      agent1 = agents[setting1.id]
      expect(agent1).to be nil
      setting2 = settings.find { |a| a.name == '2' }
      agent2 = agents[setting2.id]
      expect(agent2).not_to be nil
    end
  end

  describe '#update' do
    it 'エージェントを追加/更新/削除できる' do
      agents = {}
      settings = [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     BSON::ObjectId.from_time(Time.new),
          properties:  { a: 100, b: 'bb' }
        }, {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2',
          properties:  {}
        }, {
          agent_name:  'テスト3',
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents = agents_builder.update(agents, settings)

      settings = Jiji::Model::Agents::AgentSetting.load.map { |m| m }
      new_settings = [{
        id:          settings.find { |s| s.name == 'テスト2' }.id.to_s,
        agent_class: 'TestAgent1@aaa',
        agent_name:  'テスト11',
        icon_id:     BSON::ObjectId.from_time(Time.new),
        properties:  { a: 200, b: 'xx' }
      }, {
        id:          settings.find { |s| s.name == 'テスト3' }.id.to_s,
        agent_class: 'TestAgent1@aaa',
        agent_name:  'テスト12',
        icon_id:     BSON::ObjectId.from_time(Time.new),
        properties:  { a: 10 }
      }, {
        agent_class: 'TestAgent2@bbb',
        agent_name:  'テスト13',
        properties:  { a: 20 }
      }]
      agents = agents_builder.update(agents, new_settings)
      expect(agents.length).to be 3

      settings = Jiji::Model::Agents::AgentSetting.all.map { |m| m }
      expect(settings.length).to be 4

      setting1 = settings.find { |a| a.name == 'テスト1' }
      agent1 = agents[setting1.id]
      expect(agent1).to be nil
      expect(setting1.active).to be false

      setting2 = settings.find { |a| a.name == 'テスト11' }
      agent2 = agents[setting2.id]
      expect(agent2.properties).to eq({ 'a' => 200, 'b' => 'xx' })
      expect(agent2.broker.agent_id).to eq setting2.id
      expect(agent2.graph_factory).to eq :graph_factory
      expect(agent2.notifier.agent_id).to eq setting2.id
      expect(agent2.logger).to be logger
      expect(agent2.agent_name).to eq 'テスト11'
      expect(setting2.active).to be true
      expect(setting2.name).to eq 'テスト11'
      expect(setting2.agent_class).to eq 'TestAgent1@aaa'
      expect(setting2.icon_id).to eq new_settings[0][:icon_id]
      expect(setting2.properties).to eq({ 'a' => 200, 'b' => 'xx' })

      setting3 = settings.find { |a| a.name == 'テスト12' }
      agent3 = agents[setting3.id]
      expect(agent3).not_to be nil
      expect(agent3.properties).to eq({ 'a' => 10 })
      expect(agent3.broker.agent_id).to eq setting3.id
      expect(agent3.graph_factory).to eq :graph_factory
      expect(agent3.notifier.agent_id).to eq setting3.id
      expect(agent3.logger).to be logger
      expect(agent3.agent_name).to eq 'テスト12'
      expect(setting3.active).to be true
      expect(setting3.name).to eq 'テスト12'
      expect(setting3.agent_class).to eq 'TestAgent1@aaa'
      expect(setting3.icon_id).to eq new_settings[1][:icon_id]
      expect(setting3.properties).to eq({ 'a' => 10 })

      setting4 = settings.find { |a| a.name == 'テスト13' }
      agent4 = agents[setting4.id]
      expect(agent4).not_to be nil
      expect(agent4.properties).to eq({ 'a' => 20 })
      expect(agent4.broker.agent_id).to eq setting4.id
      expect(agent4.graph_factory).to eq :graph_factory
      expect(agent4.notifier.agent_id).to eq setting4.id
      expect(agent4.logger).to be logger
      expect(agent4.agent_name).to eq 'テスト13'
      expect(setting4.active).to be true
      expect(setting4.name).to eq 'テスト13'
      expect(setting4.agent_class).to eq 'TestAgent2@bbb'
      expect(setting4.icon_id).to eq nil
      expect(setting4.properties).to eq({ 'a' => 20 })
    end
  end

  describe '#save_state' do
    it '状態を永続化できる' do
      agents = {}
      settings = [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     BSON::ObjectId.from_time(Time.new),
          properties:  { a: 100, b: 'bb' }
        }, {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2',
          properties:  {}
        }, {
          agent_name:  'テスト3_state_nil',
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents = agents_builder.update(agents, settings)
      agents_builder.save_state(agents)

      settings = Jiji::Model::Agents::AgentSetting
                 .all.map { |s| s }.sort_by { |s| s.name }
      expect(settings.length).to be 3

      expect(settings[0].state).to eq({
        'name' => 'テスト1', 'number' => 1
      })
      expect(settings[1].state).to eq({
        'name' => 'テスト2', 'number' => 1
      })
      expect(settings[2].state).to eq(nil)
    end
    it 'Agent#stateでエラーになっても、処理は継続される' do
      agents = {}
      settings = [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     BSON::ObjectId.from_time(Time.new),
          properties:  { a: 100, b: 'bb' }
        }, {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2_state_error',
          properties:  {}
        }, {
          agent_name:  'テスト3',
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents = agents_builder.update(agents, settings)
      agents_builder.save_state(agents)

      settings = Jiji::Model::Agents::AgentSetting
                 .all.map { |s| s }.sort_by { |s| s.name }
      expect(settings.length).to be 3

      expect(settings[0].state).to eq({
        'name' => 'テスト1', 'number' => 1
      })
      expect(settings[1].state).to eq(nil)
      expect(settings[2].state).to eq({
        'name' => 'テスト3', 'number' => 2
      })
    end
  end

  describe '#restore_agents_from_saved_state' do
    it '永続化した状態からエージェントを復元できる' do
      agents = {}
      settings = [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     BSON::ObjectId.from_time(Time.new),
          properties:  { a: 100, b: 'bb' }
        }, {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2',
          properties:  {}
        }, {
          agent_name:  'テスト3',
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents = agents_builder.update(agents, settings)

      settings = Jiji::Model::Agents::AgentSetting.load.map { |m| m }
      new_settings = [{
        id:          settings.find { |s| s.name == 'テスト2' }.id.to_s,
        agent_class: 'TestAgent1@aaa',
        agent_name:  'テスト11',
        icon_id:     BSON::ObjectId.from_time(Time.new),
        properties:  { a: 200, b: 'xx' }
      }, {
        id:          settings.find { |s| s.name == 'テスト3' }.id.to_s,
        agent_class: 'TestAgent1@aaa',
        agent_name:  'テスト12',
        icon_id:     BSON::ObjectId.from_time(Time.new),
        properties:  { a: 10 }
      }, {
        agent_class: 'TestAgent2@bbb',
        agent_name:  'テスト13_state_nil',
        properties:  { a: 20 }
      }]
      agents = agents_builder.update(agents, new_settings)
      expect(agents.length).to be 3
      agents_builder.save_state(agents)

      new_agent_builder = Jiji::Model::Agents::Internal::AgentsUpdater.new(
        nil, agent_registry, components)
      agents = new_agent_builder.restore_agents_from_saved_state

      settings = Jiji::Model::Agents::AgentSetting.all.map { |m| m }
      expect(settings.length).to be 4

      setting1 = settings.find { |a| a.name == 'テスト1' }
      agent1 = agents[setting1.id]
      expect(agent1).to be nil
      expect(setting1.active).to be false

      setting2 = settings.find { |a| a.name == 'テスト11' }
      agent2 = agents[setting2.id]
      expect(agent2.properties).to eq({ 'a' => 200, 'b' => 'xx' })
      expect(agent2.broker.agent_id).to eq setting2.id
      expect(agent2.graph_factory).to eq :graph_factory
      expect(agent2.notifier.agent_id).to eq setting2.id
      expect(agent2.logger).to be logger
      expect(agent2.agent_name).to eq 'テスト11'
      expect(agent2.restored_state).to eq({
        'name' => 'テスト11', 'number' => 1
      })

      setting3 = settings.find { |a| a.name == 'テスト12' }
      agent3 = agents[setting3.id]
      expect(agent3).not_to be nil
      expect(agent3.properties).to eq({ 'a' => 10 })
      expect(agent3.broker.agent_id).to eq setting3.id
      expect(agent3.graph_factory).to eq :graph_factory
      expect(agent3.notifier.agent_id).to eq setting3.id
      expect(agent3.logger).to be logger
      expect(agent3.agent_name).to eq 'テスト12'
      expect(agent3.restored_state).to eq({
        'name' => 'テスト12', 'number' => 2
      })

      setting4 = settings.find { |a| a.name == 'テスト13_state_nil' }
      agent4 = agents[setting4.id]
      expect(agent4).not_to be nil
      expect(agent4.properties).to eq({ 'a' => 20 })
      expect(agent4.broker.agent_id).to eq setting4.id
      expect(agent4.graph_factory).to eq :graph_factory
      expect(agent4.notifier.agent_id).to eq setting4.id
      expect(agent4.logger).to be logger
      expect(agent4.agent_name).to eq 'テスト13_state_nil'
      expect(agent4.restored_state).to eq nil
    end

    it '復元の途中でエラーになっても処理は継続される' do
      agents = {}
      settings = [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     BSON::ObjectId.from_time(Time.new),
          properties:  { a: 100, b: 'bb' }
        }, {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2_restore_state_error',
          properties:  {}
        }, {
          agent_name:  'テスト3',
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents = agents_builder.update(agents, settings)
      agents_builder.save_state(agents)

      new_agent_builder = Jiji::Model::Agents::Internal::AgentsUpdater.new(
        nil, agent_registry, components)
      agents = new_agent_builder.restore_agents_from_saved_state
      expect(agents.length).to be 3

      settings = Jiji::Model::Agents::AgentSetting.all.map { |m| m }
      expect(settings.length).to be 3

      setting1 = settings.find { |a| a.name == 'テスト1' }
      agent1 = agents[setting1.id]
      expect(agent1.restored_state).to eq({
        'name' => 'テスト1', 'number' => 1
      })

      setting2 = settings.find { |a| a.name == 'テスト2_restore_state_error' }
      agent2 = agents[setting2.id]
      expect(agent2.restored_state).to eq(nil)

      setting3 = settings.find { |a| a.name == 'テスト3' }
      agent3 = agents[setting3.id]
      expect(agent3.restored_state).to eq({
        'name' => 'テスト3', 'number' => 2
      })
    end
  end

  def new_body(seed, parent = nil)
    data_builder.new_agent_body(seed, parent)
  end
end
