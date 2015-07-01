# coding: utf-8

require 'client'

describe 'グラフデータ取得' do
  before(:context) do
    register_graph
  end

  after(:context) do
    @agent_registry.remove_source('aaa')
  end

  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /graph/rmt でリアルトレードのグラフ一覧を取得できる' do
    start_time = Time.new(2015, 4, 1)
    end_time   = Time.new(2015, 4, 9)

    r = @client.get('graph/rmt',  {
      'start' => start_time.iso8601,
      'end'   => end_time.iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 2

    r.body.each do |graph|
      expect(graph['id']).not_to be nil
      expect(graph['label']).not_to be nil
      expect(graph['colors'].length).to be > 0
    end
  end

  it 'GET /graph/:bacltest_id でバックテストのグラフ一覧を取得できる' do
    start_time = Time.new(2015, 4, 1)
    end_time   = Time.new(2015, 4, 9)

    r = @client.get("graph/#{@test._id}",  {
      'start' => start_time.iso8601,
      'end'   => end_time.iso8601
    })
    expect(r.status).to eq 200
    expect(r.body.length).to be 1

    r.body.each do |graph|
      expect(graph['id']).not_to be nil
      expect(graph['label']).not_to be nil
      expect(graph['colors'].length).to be > 0
    end
  end

  it 'GET /graph/data/rmt/:interval でリアルトレードのグラフデータを取得できる' do
    start_time = Time.new(2015, 4, 1)
    end_time   = Time.new(2015, 4, 9)

    %w(one_minute one_hour one_day).each do |interval|
      r = @client.get("graph/data/rmt/#{interval}",  {
        'start' => start_time.iso8601,
        'end'   => end_time.iso8601
      })
      expect(r.status).to eq 200
      expect(r.body.values.length).to be 2

      r.body.values.each do |graph_data|
        expect(graph_data.length).to be > 0
        graph_data.each do |d|
          expect(d['id']).not_to be nil
          expect(d['timestamp']).not_to be nil
          expect(d['value'].length).to be > 0
        end
      end
    end
  end

  it 'GET /graph/data/:id/:interval でバックテストのグラフデータを取得できる' do
    start_time = Time.new(2015, 4, 1)
    end_time   = Time.new(2015, 4, 9)

    %w(one_minute one_hour one_day).each do |interval|
      r = @client.get("graph/data/#{@test._id}/#{interval}",  {
        'start' => start_time.iso8601,
        'end'   => end_time.iso8601
      })
      expect(r.status).to eq 200
      expect(r.body.values.length).to be 1

      r.body.values.each do |graph_data|
        expect(graph_data.length).to be > 0
        graph_data.each do |d|
          expect(d['id']).not_to be nil
          expect(d['timestamp']).not_to be nil
          expect(d['value'].length).to be > 0
        end
      end
    end
  end

  def register_graph
    container    = Jiji::Test::TestContainerFactory.instance.new_container
    data_builder = Jiji::Test::DataBuilder.new

    backtest_repository = container.lookup(:backtest_repository)
    @agent_registry      = container.lookup(:agent_registry)

    @agent_registry.add_source('aaa', '',
      :agent, data_builder.new_agent_body(1))
    @test = data_builder.register_backtest(1, backtest_repository)

    factory_for_rmt =
      Jiji::Model::Graphing::GraphFactory.new
    factory_for_backtest =
      Jiji::Model::Graphing::GraphFactory.new(@test)

    graph1 = factory_for_rmt.create(
      'test1', :chart,     '#333', '#666', '#999')
    graph2 = factory_for_rmt.create(
      'test2', :zero_base, '#333', '#666', '#999')

    graph3 = factory_for_backtest.create('backtest1', :chart, '#444')

    graph1 << [10, 11, 12]
    graph2 << [11,  11, 11]
    graph3 << [-1,  10, 0]

    time = Time.new(2015, 4, 2)
    graph1.save_data(time)
    graph2.save_data(time)
    graph3.save_data(time)

    graph1 << [20, 21, 22]
    graph2 << [21]

    time = Time.new(2015, 4, 2, 0, 1, 0)
    graph1.save_data(time)
    graph2.save_data(time)
    graph3.save_data(time)

    graph1 << [11,  11, 11]
    graph2 << [31, nil, 32]
    graph3 << [-10,  0, 20]

    time = Time.new(2015, 4, 2, 0, 2, 0)
    graph1.save_data(time)
    graph2.save_data(time)
    graph3.save_data(time)
  end
end
