# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Agents::AgentSource do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = @container.lookup(:agent_source_repository)

    10.times do|i|
      @data_builder.register_agent(i)
    end
  end

  after(:example) do
    @data_builder.clean
  end

  it 'get_allですべてのソースを取得できる' do
    agents = @repository.get_all

    expect(agents.length).to eq 10
    expect(agents.first.context).to eq nil
    expect(agents.first.name).to eq 'test0'
    expect(agents.first.type).to eq :agent
    expect(agents.last.context).to eq nil
    expect(agents.last.name).to eq 'test9'
    expect(agents.last.type).to eq :lib
  end

  it 'getで特定のソースを取得できる' do
    agents = @repository.get_all
    agent  = @repository.get_by_id(agents.first._id)

    expect(agent.context).not_to eq nil
    expect(agent.name).to eq 'test0'
    expect(agent.type).to eq :agent
  end

  it 'get_by_typeで特定の種類のソースを取得できる' do
    agents = @repository.get_by_type(:agent)

    expect(agents.length).to eq 5
    expect(agents.first.context).to eq nil
    expect(agents.first.name).to eq 'test0'
    expect(agents.first.type).to eq :agent
    expect(agents.last.context).to eq nil
    expect(agents.last.name).to eq 'test8'
    expect(agents.last.type).to eq :agent

    agents = @repository.get_by_type(:lib)

    expect(agents.length).to eq 5
    expect(agents.first.context).to eq nil
    expect(agents.first.name).to eq 'test1'
    expect(agents.first.type).to eq :lib
    expect(agents.last.context).to eq nil
    expect(agents.last.name).to eq 'test9'
    expect(agents.last.type).to eq :lib
  end
end
