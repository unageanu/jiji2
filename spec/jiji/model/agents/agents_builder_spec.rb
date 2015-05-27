# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Agents::AgentsBuilder do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = @container.lookup(:agent_source_repository)
    @registory    = @container.lookup(:agent_registry)

    @agents_builder = Jiji::Model::Agents::AgentsBuilder.new(
      @registory, :broker, :graph_factory, :notifier, :logger)

    @registory.add_source('aaa', '', :agent, new_body(1))
    @registory.add_source('bbb', '', :agent, new_body(2))
  end

  after(:example) do
    @data_builder.clean
  end

  describe '新規作成' do
    it 'エージェントを作成できる' do
      settings = [
        { name:'TestAgent1@aaa', properties: {a: 100, b:'bb'}},
        { name:'TestAgent1@aaa', properties: {}},
        { name:'TestAgent2@bbb'}
      ]
      agents = @agents_builder.build(settings)

      expect(settings[0][:uuid]).not_to be nil
      expect(settings[1][:uuid]).not_to be nil
      expect(settings[2][:uuid]).not_to be nil

      agent1 = agents[settings[0][:uuid]]
      expect(agent1).not_to be nil
      expect(agent1.properties).to eq( {a: 100, b:'bb'} )
      expect(agent1.broker).to eq :broker
      expect(agent1.graph_factory).to eq :graph_factory
      expect(agent1.notifier).to eq :notifier
      expect(agent1.logger).to eq :logger

      agent2 = agents[settings[1][:uuid]]
      expect(agent2).not_to be nil
      expect(agent2.properties).to eq({})
      expect(agent2.broker).to eq :broker
      expect(agent2.graph_factory).to eq :graph_factory
      expect(agent2.notifier).to eq :notifier
      expect(agent2.logger).to eq :logger

      agent3 = agents[settings[2][:uuid]]
      expect(agent3).not_to be nil
      expect(agent3.properties).to eq({})
      expect(agent3.broker).to eq :broker
      expect(agent3.graph_factory).to eq :graph_factory
      expect(agent3.notifier).to eq :notifier
      expect(agent3.logger).to eq :logger
    end

    it 'エージェントが見つからない場合エラー' do
      expect do
        @agents_builder.build([
          { name:'UnknownAgent1@unknown', properties: {}}
        ])
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe '更新' do
    it 'エージェントのプロパティを更新できる' do
      settings = [
        { name:'TestAgent1@aaa', properties: {a: 100, b:'bb'}},
        { name:'TestAgent1@aaa', properties: {}},
        { name:'TestAgent2@bbb'}
      ]
      agents = @agents_builder.build(settings)

      new_settings = [
        {uuid:settings[1][:uuid], properties: {a: 200, b:'xx'} },
        {uuid:settings[2][:uuid], properties: {a: 10 } },
        {uuid:'Unknown',          properties: {a: 20 } }
      ]
      @agents_builder.update(agents, new_settings)

      agent1 = agents[settings[0][:uuid]]
      expect(agent1).not_to be nil
      expect(agent1.properties).to eq({a: 100, b:'bb'})
      expect(agent1.broker).to eq :broker
      expect(agent1.graph_factory).to eq :graph_factory
      expect(agent1.notifier).to eq :notifier
      expect(agent1.logger).to eq :logger

      agent2 = agents[settings[1][:uuid]]
      expect(agent2).not_to be nil
      expect(agent2.properties).to eq({a: 200, b:'xx'})
      expect(agent2.broker).to eq :broker
      expect(agent2.graph_factory).to eq :graph_factory
      expect(agent2.notifier).to eq :notifier
      expect(agent2.logger).to eq :logger

      agent3 = agents[settings[2][:uuid]]
      expect(agent3).not_to be nil
      expect(agent3.properties).to eq({a: 10 })
      expect(agent3.broker).to eq :broker
      expect(agent3.graph_factory).to eq :graph_factory
      expect(agent3.notifier).to eq :notifier
      expect(agent3.logger).to eq :logger
    end
  end

  def new_body(seed, parent = nil)
    @data_builder.new_agent_body(seed, parent)
  end
end
