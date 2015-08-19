# coding: utf-8

require 'jiji/test/test_configuration'

require 'securerandom'

describe Jiji::Model::Agents::AgentsUpdater do
  include_context 'use data_builder'
  include_context 'use container'

  let(:agent_source_repository) { container.lookup(:agent_source_repository) }
  let(:agent_registry) { container.lookup(:agent_registry) }
  let(:mail_composer) { container.lookup(:mail_composer) }
  let(:push_notifier) { container.lookup(:push_notifier) }
  let(:time_source)   { container.lookup(:time_source) }
  let(:logger) { Logger.new(STDOUT) }
  let(:agents_builder) do
    Jiji::Model::Agents::AgentsUpdater.new(nil, agent_registry, :broker,
      :graph_factory, push_notifier, mail_composer, time_source, logger)
  end

  before(:example) do
    agent_registry.add_source('aaa', '', :agent, new_body(1))
    agent_registry.add_source('bbb', '', :agent, new_body(2))
  end

  after(:example) do
    data_builder.clean
  end

  describe '#build' do
    it 'エージェントを作成できる' do
      settings = [
        {
          uuid:        uuid,
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     'icon1',
          properties:  { a: 100, b: 'bb' }
        }, {
          uuid:        uuid,
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2',
          properties:  {}
        }, {
          uuid:        uuid,
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents = Jiji::Model::Agents::Agents.new
      agents_builder.update(agents, settings)

      expect(settings[0][:uuid]).not_to be nil
      expect(settings[1][:uuid]).not_to be nil
      expect(settings[2][:uuid]).not_to be nil

      agent1 = agents[settings[0][:uuid]]
      expect(agent1).not_to be nil
      expect(agent1.properties).to eq({ a: 100, b: 'bb' })
      expect(agent1.broker.agent_name).to eq 'テスト1'
      expect(agent1.broker.agent_id).to eq settings[0][:uuid]
      expect(agent1.graph_factory).to eq :graph_factory
      expect(agent1.notifier.agent_name).to eq 'テスト1'
      expect(agent1.notifier.agent_id).not_to be nil
      expect(agent1.notifier.icon).to eq 'icon1'
      expect(agent1.logger).to be logger
      expect(agent1.agent_name).to eq 'テスト1'

      agent2 = agents[settings[1][:uuid]]
      expect(agent2).not_to be nil
      expect(agent2.properties).to eq({})
      expect(agent2.broker.agent_name).to eq 'テスト2'
      expect(agent2.broker.agent_id).to eq settings[1][:uuid]
      expect(agent2.graph_factory).to eq :graph_factory
      expect(agent2.notifier.agent_name).to eq 'テスト2'
      expect(agent2.notifier.agent_id).not_to be nil
      expect(agent2.notifier.icon).to be nil
      expect(agent2.logger).to be logger
      expect(agent2.agent_name).to eq 'テスト2'

      agent3 = agents[settings[2][:uuid]]
      expect(agent3).not_to be nil
      expect(agent3.properties).to eq({})
      expect(agent3.broker.agent_name).to eq 'TestAgent2@bbb'
      expect(agent3.broker.agent_id).to eq settings[2][:uuid]
      expect(agent3.graph_factory).to eq :graph_factory
      expect(agent3.notifier.agent_name).to eq 'TestAgent2@bbb'
      expect(agent3.notifier.agent_id).not_to be nil
      expect(agent3.notifier.icon).to be nil
      expect(agent3.logger).to be logger
      expect(agent3.agent_name).to eq 'TestAgent2@bbb'
    end

    it 'fail_on_error=trueで エージェントが見つからない場合エラー' do
      agents = Jiji::Model::Agents::Agents.new
      expect do
        agents_builder.update(agents, [
          { uuid: uuid, agent_class: 'UnknownAgent1@unknown', properties: {} }
        ], true)
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end

    it 'エージェントが見つからない場合でもfail_on_error=falseの場合エラーにはならない' do
      agents = Jiji::Model::Agents::Agents.new
      settings = [
        { uuid: uuid, agent_class: 'UnknownAgent1@unknown', properties: {} },
        { uuid: uuid, agent_class: 'TestAgent2@bbb' }
      ]
      agents_builder.update(agents, settings)

      agent1 = agents[settings[0][:uuid]]
      expect(agent1).to be nil
      agent2 = agents[settings[1][:uuid]]
      expect(agent2).not_to be nil
    end
  end

  describe '#update' do
    it 'エージェントを追加/更新/削除できる' do
      agents = Jiji::Model::Agents::Agents.new

      settings = [
        {
          uuid:        uuid,
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          icon_id:     'icon1',
          properties:  { a: 100, b: 'bb' }
        }, {
          uuid:        uuid,
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2',
          properties:  {}
        }, {
          uuid:        uuid,
          agent_class: 'TestAgent2@bbb'
        }
      ]
      agents_builder.update(agents, settings)

      new_settings = [{
        uuid:        settings[1][:uuid],
        agent_class: 'TestAgent1@aaa',
        agent_name:  'テスト11',
        icon_id:     'icon11',
        properties:  { a: 200, b: 'xx' }
      }, {
        uuid:        settings[2][:uuid],
        agent_class: 'TestAgent1@aaa',
        agent_name:  'テスト12',
        icon_id:     'icon12',
        properties:  { a: 10 }
      }, {
        uuid:        uuid,
        agent_class: 'TestAgent2@bbb',
        properties:  { a: 20 }
      }]
      agents_builder.update(agents, new_settings)

      agent1 = agents[settings[0][:uuid]]
      expect(agent1).to be nil

      agent2 = agents[settings[1][:uuid]]
      expect(agent2).not_to be nil
      expect(agent2.properties).to eq({ a: 200, b: 'xx' })
      expect(agent2.broker.agent_name).to eq 'テスト11'
      expect(agent2.broker.agent_id).to eq settings[1][:uuid]
      expect(agent2.graph_factory).to eq :graph_factory
      expect(agent2.notifier.agent_name).to eq 'テスト11'
      expect(agent2.notifier.agent_id).not_to be nil
      expect(agent2.notifier.icon).to eq 'icon11'
      expect(agent2.logger).to be logger
      expect(agent2.agent_name).to eq 'テスト11'

      agent3 = agents[settings[2][:uuid]]
      expect(agent3).not_to be nil
      expect(agent3.properties).to eq({ a: 10 })
      expect(agent3.broker.agent_name).to eq 'テスト12'
      expect(agent3.broker.agent_id).to eq settings[2][:uuid]
      expect(agent3.graph_factory).to eq :graph_factory
      expect(agent3.notifier.agent_name).to eq 'テスト12'
      expect(agent3.notifier.agent_id).not_to be nil
      expect(agent3.notifier.icon).to eq 'icon12'
      expect(agent3.logger).to be logger
      expect(agent3.agent_name).to eq 'テスト12'

      agent4 = agents[new_settings[2][:uuid]]
      expect(agent4).not_to be nil
      expect(agent4.properties).to eq({ a: 20 })
      expect(agent4.broker.agent_name).to eq 'TestAgent2@bbb'
      expect(agent4.broker.agent_id).to eq new_settings[2][:uuid]
      expect(agent4.graph_factory).to eq :graph_factory
      expect(agent4.notifier.agent_name).to eq 'TestAgent2@bbb'
      expect(agent4.notifier.agent_id).not_to be nil
      expect(agent4.logger).to be logger
      expect(agent4.agent_name).to eq 'TestAgent2@bbb'
    end
  end

  def new_body(seed, parent = nil)
    data_builder.new_agent_body(seed, parent)
  end

  def uuid
    SecureRandom.uuid
  end
end
