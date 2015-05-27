# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Utils::Pagenation::Query do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @time_srouce = Jiji::Utils::TimeSource.new
    factory = Jiji::Model::Graphing::GraphFactory.new(@time_srouce)
    @graph1 = factory.create('test1', :chart)
    @graph2 = factory.create('test2', :chart)

    100.times do |i|
      @time_srouce.set(Time.at(i))
      @graph1 << [i]
      @graph2 << [i]
    end
  end

  after(:example) do
    @data_builder.clean
  end

  it '絞り込み条件あり、ソート条件あり、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id }, { timestamp: :asc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].values).to eq([0])
    expect(data[0].timestamp).to eq(Time.at(0))
    expect(data[9].values).to eq([9])
    expect(data[9].timestamp).to eq(Time.at(9))
  end

  it '絞り込み条件あり、ソート条件あり、10～20件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id }, { timestamp: :asc }, 10, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].values).to eq([10])
    expect(data[0].timestamp).to eq(Time.at(10))
    expect(data[9].values).to eq([19])
    expect(data[9].timestamp).to eq(Time.at(19))
  end

  it '絞り込み条件あり、ソート条件あり、95～100件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id }, { timestamp: :asc }, 95, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(5)
    expect(data[0].values).to eq([95])
    expect(data[0].timestamp).to eq(Time.at(95))
    expect(data[4].values).to eq([99])
    expect(data[4].timestamp).to eq(Time.at(99))
  end

  it '絞り込み条件あり、ソート条件あり(逆順)、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id }, { timestamp: :desc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].values).to eq([99])
    expect(data[0].timestamp).to eq(Time.at(99))
    expect(data[9].values).to eq([90])
    expect(data[9].timestamp).to eq(Time.at(90))
  end

  it '絞り込み条件あり、ソート条件あり(逆順)、10～20件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id }, { timestamp: :desc }, 10, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].values).to eq([89])
    expect(data[0].timestamp).to eq(Time.at(89))
    expect(data[9].values).to eq([80])
    expect(data[9].timestamp).to eq(Time.at(80))
  end

  it '絞り込み条件あり、ソート条件あり(逆順)、95～100件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id }, { timestamp: :desc }, 95, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(5)
    expect(data[0].values).to eq([4])
    expect(data[0].timestamp).to eq(Time.at(4))
    expect(data[4].values).to eq([0])
    expect(data[4].timestamp).to eq(Time.at(0))
  end

  it '絞り込み条件なし、ソート条件あり、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      nil, { graph_id: :asc, timestamp: :asc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].values).to eq([0])
    expect(data[0].timestamp).to eq(Time.at(0))
    expect(data[9].values).to eq([9])
    expect(data[9].timestamp).to eq(Time.at(9))
  end

  it '絞り込み条件なし、ソート条件あり(逆順)、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      nil, { graph_id: :desc, timestamp: :desc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].values).to eq([99])
    expect(data[0].timestamp).to eq(Time.at(99))
    expect(data[9].values).to eq([90])
    expect(data[9].timestamp).to eq(Time.at(90))
  end

  it '絞り込み条件なし、ソート条件なし、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(nil, nil, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
  end

  it '絞り込み条件なし、ソート条件なし、全件取得' do
    q = Jiji::Utils::Pagenation::Query.new
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(200)
  end

  it '絞り込み条件あり、ソート条件あり、全件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id }, timestamp: :asc)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(100)
    expect(data[0].values).to eq([0])
    expect(data[0].timestamp).to eq(Time.at(0))
    expect(data[99].values).to eq([99])
    expect(data[99].timestamp).to eq(Time.at(99))
  end
end
