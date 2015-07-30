# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Utils::Pagenation::Query do
  include_context 'use data_builder'
  let(:time_source) { Jiji::Utils::TimeSource.new }

  before(:example) do
    factory = Jiji::Model::Graphing::GraphFactory.new
    @graph1 = factory.create('test1', :chart, :last)
    @graph2 = factory.create('test2', :chart, :first)

    interval = Jiji::Model::Trading::Intervals.instance.get(:one_minute)
    saver1 = Jiji::Model::Graphing::Internal::GraphDataSaver.new(
      @graph1, interval)
    saver2 = Jiji::Model::Graphing::Internal::GraphDataSaver.new(
      @graph2, interval)

    101.times do |i|
      saver1.save_data_if_required([i], Time.at(i * 60))
      saver2.save_data_if_required([i], Time.at(i * 60))
    end
  end

  it '絞り込み条件あり、ソート条件あり、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id, interval: :one_minute },
      { timestamp: :asc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].value).to eq([0])
    expect(data[0].timestamp).to eq(Time.at(0))
    expect(data[9].value).to eq([9])
    expect(data[9].timestamp).to eq(Time.at(9 * 60))
  end

  it '絞り込み条件あり、ソート条件あり、10～20件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id, interval: :one_minute  },
      { timestamp: :asc }, 10, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].value).to eq([10])
    expect(data[0].timestamp).to eq(Time.at(10 * 60))
    expect(data[9].value).to eq([19])
    expect(data[9].timestamp).to eq(Time.at(19 * 60))
  end

  it '絞り込み条件あり、ソート条件あり、95～100件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id, interval: :one_minute },
      { timestamp: :asc }, 95, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(5)
    expect(data[0].value).to eq([95])
    expect(data[0].timestamp).to eq(Time.at(95 * 60))
    expect(data[4].value).to eq([99])
    expect(data[4].timestamp).to eq(Time.at(99 * 60))
  end

  it '絞り込み条件あり、ソート条件あり(逆順)、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id, interval: :one_minute },
      { timestamp: :desc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].value).to eq([99])
    expect(data[0].timestamp).to eq(Time.at(99 * 60))
    expect(data[9].value).to eq([90])
    expect(data[9].timestamp).to eq(Time.at(90 * 60))
  end

  it '絞り込み条件あり、ソート条件あり(逆順)、10～20件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id, interval: :one_minute },
      { timestamp: :desc }, 10, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].value).to eq([89])
    expect(data[0].timestamp).to eq(Time.at(89 * 60))
    expect(data[9].value).to eq([80])
    expect(data[9].timestamp).to eq(Time.at(80 * 60))
  end

  it '絞り込み条件あり、ソート条件あり(逆順)、95～100件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      { graph_id: @graph1.id, interval: :one_minute },
      { timestamp: :desc }, 95, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(5)
    expect(data[0].value).to eq([4])
    expect(data[0].timestamp).to eq(Time.at(4 * 60))
    expect(data[4].value).to eq([0])
    expect(data[4].timestamp).to eq(Time.at(0))
  end

  it '絞り込み条件なし、ソート条件あり、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      nil, { graph_id: :asc, timestamp: :asc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].value).to eq([0])
    expect(data[0].timestamp).to eq(Time.at(0))
    expect(data[9].value).to eq([9])
    expect(data[9].timestamp).to eq(Time.at(9 * 60))
  end

  it '絞り込み条件なし、ソート条件あり(逆順)、0～10件取得' do
    q = Jiji::Utils::Pagenation::Query.new(
      nil, { graph_id: :desc, timestamp: :desc }, 0, 10)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(10)
    expect(data[0].value).to eq([99])
    expect(data[0].timestamp).to eq(Time.at(99 * 60))
    expect(data[9].value).to eq([90])
    expect(data[9].timestamp).to eq(Time.at(90 * 60))
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
      { graph_id: @graph1.id, interval: :one_minute }, timestamp: :asc)
    data = q.execute(Jiji::Model::Graphing::GraphData).map { |x| x }

    expect(data.length).to eq(100)
    expect(data[0].value).to eq([0])
    expect(data[0].timestamp).to eq(Time.at(0))
    expect(data[99].value).to eq([99])
    expect(data[99].timestamp).to eq(Time.at(99 * 60))
  end
end
