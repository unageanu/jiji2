# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Graphing::GraphFactory do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container = Jiji::Test::TestContainerFactory.instance.new_container
    @repository         = @container.lookup(:graph_repository)
    @time_srouce        = @container.lookup(:time_source)
    @registory          = @container.lookup(:agent_registry)

    @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))

    backtest_repository = @container.lookup(:backtest_repository)
    @backtest1 = @data_builder.register_backtest(1, backtest_repository)
    @backtest2 = @data_builder.register_backtest(2, backtest_repository)
  end

  after(:example) do
    @data_builder.clean
  end

  it '同じ名前のグラフを作成すると、同じインスタンスが返される' do
    factory_for_rmt =
      Jiji::Model::Graphing::GraphFactory.new
    factory_for_backtest1 =
      Jiji::Model::Graphing::GraphFactory.new(@backtest1.id)

    graph1 = factory_for_rmt.create(
      'test1', :chart,     '#333', '#666', '#999')
    graph2 = factory_for_rmt.create(
      'test1', :chart,     '#444', '#666', '#999')
    graph3 = factory_for_backtest1.create(
      'test1', :chart,     '#333', '#666', '#999')

    expect(graph1).to be graph2
    expect(graph1).not_to be graph3
    expect(graph1.colors).to eq ['#333', '#666', '#999']
    expect(graph2.colors).to eq ['#333', '#666', '#999']
    expect(graph3.colors).to eq ['#333', '#666', '#999']

    # factory を再作成した場合も、graph_idを引き継ぐ
    factory_for_rmt =
      Jiji::Model::Graphing::GraphFactory.new
    factory_for_backtest1 =
      Jiji::Model::Graphing::GraphFactory.new(@backtest1.id)

    graph10 = factory_for_rmt.create(
      'test1', :chart,     '#133', '#666', '#999')
    graph20 = factory_for_rmt.create(
      'test1', :chart,     '#144', '#666', '#999')
    graph30 = factory_for_backtest1.create(
      'test1', :chart,     '#133', '#666', '#999')

    expect(graph1.id).to eq graph10.id
    expect(graph1.id).to eq graph20.id
    expect(graph1.id).not_to eq graph30.id
    expect(graph3.id).to eq graph30.id
    expect(graph10.colors).to eq ['#333', '#666', '#999']
    expect(graph20.colors).to eq ['#333', '#666', '#999']
    expect(graph30.colors).to eq ['#333', '#666', '#999']
  end
end
