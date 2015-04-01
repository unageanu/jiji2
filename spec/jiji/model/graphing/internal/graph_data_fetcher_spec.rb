# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Graphing::Internal::GraphDataFetcher do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container = Jiji::Composing::ContainerFactory.instance.new_container
    @repository         = @container.lookup(:graph_repository)
    @time_srouce        = @container.lookup(:time_source)

    register_graph
  end

  after(:example) do
    @data_builder.clean
  end

  it 'グラフのデータを取り出せる' do
    graphs = @repository.find

    data = graphs[0].fetch_data(Time.at(0), Time.at(200))
    expect(data.length).to eq 4
    expect(data[0][:timestamp]).to eq Time.at(0)
    expect(data[0][:values]).to eq [1, -4, -0.4]
    expect(data[1][:timestamp]).to eq Time.at(60)
    expect(data[1][:values]).to eq [4, -1, -0.1]
    expect(data[2][:timestamp]).to eq Time.at(120)
    expect(data[2][:values]).to eq [7, 2, 0.2]
    expect(data[3][:timestamp]).to eq Time.at(180)
    expect(data[3][:values]).to eq [9, 4, 0.4]

    data = graphs[0].fetch_data(Time.at(200), Time.at(400))
    expect(data.length).to eq 4
    expect(data[0][:timestamp]).to eq Time.at(180)
    expect(data[0][:values]).to eq [0.5, -4.5, -0.45]
    expect(data[1][:timestamp]).to eq Time.at(240)
    expect(data[1][:values]).to eq [3.0, -2.0, -0.2]
    expect(data[2][:timestamp]).to eq Time.at(300)
    expect(data[2][:values]).to eq [6.0, 1.0, 0.1]
    expect(data[3][:timestamp]).to eq Time.at(360)
    expect(data[3][:values]).to eq [8.5, 3.5, 0.35]

    data = graphs[0].fetch_data(Time.at(39_900), Time.at(40_100))
    expect(data.length).to eq 2
    expect(data[0][:timestamp]).to eq Time.at(39_900)
    expect(data[0][:values]).to eq [6.0, 1.0, 0.1]
    expect(data[1][:timestamp]).to eq Time.at(39_960)
    expect(data[1][:values]).to eq [8.5, 3.5, 0.35]

    data = graphs[0].fetch_data(Time.at(0), Time.at(40_100), :one_hour)
    expect(data.length).to eq 12
    expect(data[0][:timestamp]).to eq Time.at(0)
    expect(data[0][:values]).to eq [4.5, -0.5, -0.05]
    expect(data[11][:timestamp]).to eq Time.at(39_600)
    expect(data[11][:values]).to eq [4.5, -0.5, -0.05]

    data = graphs[0].fetch_data(Time.at(0), Time.at(40_100), :one_day)
    expect(data.length).to eq 1
    expect(data[0][:timestamp]).to eq Time.at(0)
    expect(data[0][:values]).to eq [4.5, -0.5, -0.05]

    data = graphs[1].fetch_data(Time.at(0), Time.at(200))
    expect(data.length).to eq 4
    expect(data[0][:timestamp]).to eq Time.at(0)
    expect(data[0][:values]).to eq [-2.0, 0, -0.6]
    expect(data[1][:timestamp]).to eq Time.at(60)
    expect(data[1][:values]).to eq [-6.0, 0, -0.9]
    expect(data[2][:timestamp]).to eq Time.at(120)
    expect(data[2][:values]).to eq [-4.0, 0, -1.2]
    expect(data[3][:timestamp]).to eq Time.at(180)
    expect(data[3][:values]).to eq [-14.0, 0, -1.4]
  end

  def register_graph
    factory = Jiji::Model::Graphing::GraphFactory.new(@time_srouce)
    graph1 = factory.create('test1', :chart, '#333', '#666', '#999')
    graph2 = factory.create('test2', :chart, '#333', '#666', '#999')

    2000.times do |i|
      n = i % 10
      @time_srouce.set(Time.at(i * 20))
      graph1 << [n, -5 + n, -0.5 + 0.1 * n]
      graph2 << (i.even? ? [nil, nil] : [-5 - n, nil, -0.5 - 0.1 * n])
    end
  end
end
