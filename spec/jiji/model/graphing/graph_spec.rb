# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Graphing::Graph do
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

    register_graphs
  end

  after(:example) do
    @data_builder.clean
  end

  it 'グラフを作成して永続化できる' do
    rmt_graphs = @repository.find
    expect(rmt_graphs.length).to eq 2

    expect(rmt_graphs[0].label).to eq 'test1'
    expect(rmt_graphs[0].type).to eq :chart
    expect(rmt_graphs[0].colors).to eq ['#333', '#666', '#999']
    expect(rmt_graphs[0].start_time).to eq Time.new(2015, 4, 1)
    expect(rmt_graphs[0].end_time).to eq Time.new(2015, 4, 1, 0, 1, 0)

    expect(rmt_graphs[1].label).to eq 'test2'
    expect(rmt_graphs[1].type).to eq :zero_base
    expect(rmt_graphs[1].colors).to eq ['#333', '#666', '#999']
    expect(rmt_graphs[1].start_time).to eq Time.new(2015, 4, 1)
    expect(rmt_graphs[1].end_time).to eq Time.new(2015, 4, 1, 0, 2, 0)

    graphs = @repository.find(@backtest1.id)
    expect(graphs.length).to eq 1
    expect(graphs[0].label).to eq 'backtest1'
    expect(graphs[0].type).to eq :chart
    expect(graphs[0].colors).to eq ['#444']
    expect(graphs[0].start_time).to eq Time.new(2015, 4, 1)
    expect(graphs[0].end_time).to eq Time.new(2015, 4, 1, 0, 2, 0)

    graphs = @repository.find(@backtest2.id)
    expect(graphs.length).to eq 1
    expect(graphs[0].label).to eq 'backtest2'
    expect(graphs[0].type).to eq :zero_base
    expect(graphs[0].colors).to eq []
    expect(graphs[0].start_time).to eq Time.new(2015, 4, 1)
    expect(graphs[0].end_time).to eq Time.new(2015, 4, 1, 0, 1, 0)
  end

  it '期間を指定して期間内にデータがあるグラフを取り出せる' do
    graphs = @repository.find(nil,
      Time.new(2015, 3, 31), Time.new(2015, 4, 31))
    expect(graphs.length).to eq 2
    expect(graphs[0].label).to eq 'test1'
    expect(graphs[1].label).to eq 'test2'

    graphs = @repository.find(nil,
      Time.new(2015, 4, 1), Time.new(2015, 4, 1, 0, 1, 0))
    expect(graphs.length).to eq 2
    expect(graphs[0].label).to eq 'test1'
    expect(graphs[1].label).to eq 'test2'

    graphs = @repository.find(nil,
      Time.new(2015, 4, 1, 0, 2, 0), Time.new(2015, 4, 1, 0, 3, 0))
    expect(graphs.length).to eq 1
    expect(graphs[0].label).to eq 'test2'

    graphs = @repository.find(nil,
      Time.new(2015, 3, 31, 0, 2, 0), Time.new(2015, 4, 1))
    expect(graphs.length).to eq 0

    graphs = @repository.find(nil,
      Time.new(2015, 4, 1, 0, 3, 0), Time.new(2015, 4, 1, 0, 1))
    expect(graphs.length).to eq 0

    graphs = @repository.find(@backtest1.id,
      Time.new(2015, 3, 31), Time.new(2015, 4, 31))
    expect(graphs.length).to eq 1
    expect(graphs[0].label).to eq 'backtest1'

    graphs = @repository.find(@backtest1.id,
      Time.new(2015, 3, 31), Time.new(2015, 4, 1))
    expect(graphs.length).to eq 0

    graphs = @repository.find(@backtest1.id,
      Time.new(2015, 4, 1, 0, 2, 0), Time.new(2015, 4, 1, 0, 3, 0))
    expect(graphs.length).to eq 1
    expect(graphs[0].label).to eq 'backtest1'

    graphs = @repository.find(@backtest1.id,
      Time.new(2015, 4, 1, 0, 3, 0), Time.new(2015, 4, 1, 0, 4))
    expect(graphs.length).to eq 0
  end

  it 'バックテストIDを指定してグラフを削除できる' do
    graph1 = @repository.find(@backtest1.id)[0]
    graph2 = @repository.find(@backtest2.id)[0]
    start_time  = Time.new(2015, 4, 1)
    end_time    = Time.new(2015, 4, 2)

    expect(graph1.fetch_data(start_time, end_time).length).not_to eq 0
    expect(graph2.fetch_data(start_time, end_time).length).not_to eq 0

    @repository.delete_backtest_graphs(@backtest1.id)

    graphs = @repository.find(@backtest1.id)
    expect(graphs.length).to eq 0

    graphs = @repository.find(@backtest2.id)
    expect(graphs.length).to eq 1

    expect(graph1.fetch_data(start_time, end_time).length).to eq 0
    expect(graph2.fetch_data(start_time, end_time).length).not_to eq 0

    @repository.delete_backtest_graphs(@backtest2.id)

    graphs = @repository.find(@backtest1.id)
    expect(graphs.length).to eq 0

    graphs = @repository.find(@backtest2.id)
    expect(graphs.length).to eq 0

    expect(graph1.fetch_data(start_time, end_time).length).to eq 0
    expect(graph2.fetch_data(start_time, end_time).length).to eq 0
  end

  it '期間を指定してリアルトレードのグラフを削除できる' do
    graph = @repository.find[0]
    start_time  = Time.new(2015, 4, 1)
    end_time    = Time.new(2015, 4, 1, 0, 0, 2)

    expect(graph.fetch_data(start_time, end_time).length).to eq 1

    @repository.delete_rmt_graphs(Time.new(2015, 4, 1, 0, 0, 2))

    graphs = @repository.find
    expect(graphs.length).to eq 2

    expect(graph.fetch_data(start_time, end_time).length).to eq 0
  end

  it 'to_h でハッシュに変換できる' do
    graph = @repository.find[0]
    hash = graph.to_h
    expect(hash[:id]).to eq graph._id
    expect(hash[:label]).to eq graph.label
    expect(hash[:colors]).to eq graph.colors
  end

  it '永続化データから作成されたGraphにもデータを追加できる' do
    graph = Jiji::Model::Graphing::Graph.get_or_create(
      'test1', :chart, ['#444', '#666', '#999'])

    graph << [10, 11, 12]
    time = Time.new(2015, 4, 1, 0, 3, 0)
    graph.save_data(time)

    graph << [10, 11, 12]
    time = Time.new(2015, 4, 1, 0, 4, 0)
    graph.save_data(time)

    start_time  = Time.new(2015, 4, 1)
    end_time    = Time.new(2015, 4, 2)
    expect(graph.fetch_data(start_time, end_time).length).to eq 2
  end


  def register_graphs
    factory_for_rmt =
      Jiji::Model::Graphing::GraphFactory.new
    factory_for_backtest1 =
      Jiji::Model::Graphing::GraphFactory.new(@backtest1)
    factory_for_backtest2 =
      Jiji::Model::Graphing::GraphFactory.new(@backtest2)

    graph1 = factory_for_rmt.create(
      'test1', :chart,     '#333', '#666', '#999')
    graph2 = factory_for_rmt.create(
      'test2', :zero_base, '#333', '#666', '#999')

    graph3 = factory_for_backtest1.create('backtest1', :chart,    '#444')
    graph4 = factory_for_backtest2.create('backtest2', :zero_base)

    graph1 << [10, 11, 12]
    graph2 << [11,  11, 11]
    graph3 << [-1,  10, 0]
    graph4 << [0.1,  0.2, 0.3]

    time = Time.new(2015, 4, 1)
    graph1.save_data(time)
    graph2.save_data(time)
    graph3.save_data(time)
    graph4.save_data(time)

    graph1 << [20, 21, 22]
    graph2 << [21]
    graph4 << [0.4,  0.2, -0.3]

    time = Time.new(2015, 4, 1, 0, 1, 0)
    graph1.save_data(time)
    graph2.save_data(time)
    graph3.save_data(time)
    graph4.save_data(time)

    graph2 << [31, nil, 32]
    graph3 << [-10,  0, 20]

    time = Time.new(2015, 4, 1, 0, 2, 0)
    graph1.save_data(time)
    graph2.save_data(time)
    graph3.save_data(time)
    graph4.save_data(time)
  end
end
