# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Graphing::Internal::GraphDataSaver do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container = Jiji::Test::TestContainerFactory.instance.new_container
    @repository         = @container.lookup(:graph_repository)
    @registory          = @container.lookup(:agent_registry)

    @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))

    backtest_repository = @container.lookup(:back_test_repository)
    @backtest1 = @data_builder.register_back_test(1, backtest_repository)

    factory = Jiji::Model::Graphing::GraphFactory.new(@backtest1.id)
    @graph = factory.create('test1', :chart, '#333', '#666', '#999')
  end

  after(:example) do
    @data_builder.clean
  end

  it 'グラフデータを永続化できる' do
    Jiji::Model::Trading::Intervals.instance.all.each do |i|
      expect(fetch_data(i.id).length).to be 0
    end

    @graph << [10, -1,  1.2]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 0, 0))

    Jiji::Model::Trading::Intervals.instance.all.each do |i|
      data = fetch_data(i.id)
      expect(data.length).to be 0
    end

    @graph << [12,  -3,  1.4]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 0, 50))

    Jiji::Model::Trading::Intervals.instance.all.each do |i|
      data = fetch_data(i.id)
      expect(data.length).to be 0
    end

    @graph << [11,  -2,  1.3]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 1, 0))

    Jiji::Model::Trading::Intervals.instance.all.each do |i|
      data = fetch_data(i.id)
      expect(data.length).to be 1
      expect(data[0].values).to eq [11, -2, 1.3]
      expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    end

    @graph << [10,  -5,  1.1]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 2, 1))

    data = fetch_data(:one_minute)
    expect(data.length).to be 2
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)

    [:fifteen_minutes, :thirty_minutes,
     :one_hour, :six_hours, :one_day].each do |i|
      data = fetch_data(i)
      expect(data.length).to be 1
      expect(data[0].values).to eq [10.75, -2.75, 1.25]
      expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    end

    @graph << [12,  -4,  0] # 5: 55, -15, 5
    @graph.save_data(Time.utc(2015, 4, 1, 0, 14, 59))

    data = fetch_data(:one_minute)
    expect(data.length).to be 3
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)

    [:fifteen_minutes, :thirty_minutes,
     :one_hour, :six_hours, :one_day].each do |i|
      data = fetch_data(i)
      expect(data.length).to be 1
      expect(data[0].values).to eq [11, -3, 1]
      expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    end

    @graph << [11,  -3,  1.6] # 6: 66, -18, 6.6
    @graph.save_data(Time.utc(2015, 4, 1, 0, 15, 0))

    data = fetch_data(:one_minute)
    expect(data.length).to be 4
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)
    expect(data[3].values).to eq [12,  -4,  0]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 0, 14, 0)

    data = fetch_data(:fifteen_minutes)
    expect(data.length).to be 1
    expect(data[0].values).to eq [11, -3, 1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)

    [:thirty_minutes, :one_hour, :six_hours, :one_day].each do |i|
      data = fetch_data(i)
      expect(data.length).to be 1
      expect(data[0].values).to eq [11, -3, 1.1]
      expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    end

    @graph << [4,  -3,  1.1] # 7: 70, -21, 7.7
    @graph.save_data(Time.utc(2015, 4, 1, 0, 30, 0))

    data = fetch_data(:one_minute)
    expect(data.length).to be 5
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)
    expect(data[3].values).to eq [12,  -4,  0]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 0, 14, 0)
    expect(data[4].values).to eq [11,  -3,  1.6]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)

    data = fetch_data(:fifteen_minutes)
    expect(data.length).to be 2
    expect(data[0].values).to eq [11, -3, 1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11,  -3,  1.6]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)

    data = fetch_data(:thirty_minutes)
    expect(data.length).to be 1
    expect(data[0].values).to eq [11, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)

    [:one_hour, :six_hours, :one_day].each do |i|
      data = fetch_data(i)
      expect(data.length).to be 1
      expect(data[0].values).to eq [10, -3, 1.1]
      expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    end

    @graph << [18,  -11,  1.9] # 8: 88, -32, 9.6
    @graph.save_data(Time.utc(2015, 4, 1, 1, 0, 0))

    data = fetch_data(:one_minute)
    expect(data.length).to be 6
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)
    expect(data[3].values).to eq [12,  -4,  0]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 0, 14, 0)
    expect(data[4].values).to eq [11,  -3,  1.6]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[5].values).to eq [4,  -3,  1.1]
    expect(data[5].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)

    data = fetch_data(:fifteen_minutes)
    expect(data.length).to be 3
    expect(data[0].values).to eq [11, -3, 1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0,  0, 0)
    expect(data[1].values).to eq [11,  -3,  1.6]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[2].values).to eq [4,  -3,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)

    data = fetch_data(:thirty_minutes)
    expect(data.length).to be 2
    expect(data[0].values).to eq [11, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [4,  -3,  1.1]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)

    data = fetch_data(:one_hour)
    expect(data.length).to be 1
    expect(data[0].values).to eq [10, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)

    [:six_hours, :one_day].each do |i|
      data = fetch_data(i)
      expect(data.length).to be 1
      expect(data[0].values).to eq [11, -4, 1.2]
      expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    end

    @graph << [11,  -13,  1.2] # 9: 99, -45, 10.8
    @graph.save_data(Time.utc(2015, 4, 1, 6, 0, 0))

    data = fetch_data(:one_minute)
    expect(data.length).to be 7
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)
    expect(data[3].values).to eq [12,  -4,  0]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 0, 14, 0)
    expect(data[4].values).to eq [11,  -3,  1.6]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[5].values).to eq [4,  -3,  1.1]
    expect(data[5].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[6].values).to eq [18,  -11,  1.9]
    expect(data[6].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)

    data = fetch_data(:fifteen_minutes)
    expect(data.length).to be 4
    expect(data[0].values).to eq [11, -3, 1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0,  0, 0)
    expect(data[1].values).to eq [11,  -3,  1.6]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[2].values).to eq [4,  -3,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[3].values).to eq [18,  -11,  1.9]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)

    data = fetch_data(:thirty_minutes)
    expect(data.length).to be 3
    expect(data[0].values).to eq [11, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [4,  -3,  1.1]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[2].values).to eq [18,  -11,  1.9]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)

    data = fetch_data(:one_hour)
    expect(data.length).to be 2
    expect(data[0].values).to eq [10, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [18,  -11,  1.9]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)

    data = fetch_data(:six_hours)
    expect(data.length).to be 1
    expect(data[0].values).to eq [11, -4, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)

    data = fetch_data(:one_day)
    expect(data.length).to be 1
    expect(data[0].values).to eq [11, -5, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)

    @graph << [1,  -10,  2.2] # 10: 100, -55, 13
    @graph.save_data(Time.utc(2015, 4, 2, 0, 0, 0))

    data = fetch_data(:one_minute)
    expect(data.length).to be 8
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)
    expect(data[3].values).to eq [12,  -4,  0]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 0, 14, 0)
    expect(data[4].values).to eq [11,  -3,  1.6]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[5].values).to eq [4,  -3,  1.1]
    expect(data[5].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[6].values).to eq [18,  -11,  1.9]
    expect(data[6].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[7].values).to eq [11,  -13,  1.2]
    expect(data[7].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:fifteen_minutes)
    expect(data.length).to be 5
    expect(data[0].values).to eq [11, -3, 1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0,  0, 0)
    expect(data[1].values).to eq [11,  -3,  1.6]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[2].values).to eq [4,  -3,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[3].values).to eq [18,  -11,  1.9]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[4].values).to eq [11,  -13,  1.2]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:thirty_minutes)
    expect(data.length).to be 4
    expect(data[0].values).to eq [11, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [4,  -3,  1.1]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[2].values).to eq [18,  -11,  1.9]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[3].values).to eq [11,  -13,  1.2]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:one_hour)
    expect(data.length).to be 3
    expect(data[0].values).to eq [10, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [18,  -11,  1.9]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[2].values).to eq [11,  -13,  1.2]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:six_hours)
    expect(data.length).to be 2
    expect(data[0].values).to eq [11, -4, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11,  -13,  1.2]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:one_day)
    expect(data.length).to be 1
    expect(data[0].values).to eq [11, -5, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)

    @graph << [3,  -12,  0.8]
    @graph.save_data(Time.utc(2015, 4, 2, 0, 0, 10))

    data = fetch_data(:one_minute)
    expect(data.length).to be 8
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)
    expect(data[3].values).to eq [12,  -4,  0]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 0, 14, 0)
    expect(data[4].values).to eq [11,  -3,  1.6]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[5].values).to eq [4,  -3,  1.1]
    expect(data[5].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[6].values).to eq [18,  -11,  1.9]
    expect(data[6].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[7].values).to eq [11,  -13,  1.2]
    expect(data[7].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:fifteen_minutes)
    expect(data.length).to be 5
    expect(data[0].values).to eq [11, -3, 1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0,  0, 0)
    expect(data[1].values).to eq [11,  -3,  1.6]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[2].values).to eq [4,  -3,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[3].values).to eq [18,  -11,  1.9]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[4].values).to eq [11,  -13,  1.2]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:thirty_minutes)
    expect(data.length).to be 4
    expect(data[0].values).to eq [11, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [4,  -3,  1.1]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[2].values).to eq [18,  -11,  1.9]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[3].values).to eq [11,  -13,  1.2]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:one_hour)
    expect(data.length).to be 3
    expect(data[0].values).to eq [10, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [18,  -11,  1.9]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[2].values).to eq [11,  -13,  1.2]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:six_hours)
    expect(data.length).to be 2
    expect(data[0].values).to eq [11, -4, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11,  -13,  1.2]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)

    data = fetch_data(:one_day)
    expect(data.length).to be 1
    expect(data[0].values).to eq [11, -5, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)

    @graph << [2,  -11,  1.5]
    @graph.save_data(Time.utc(2015, 4, 2, 0, 1, 0))

    data = fetch_data(:one_minute)
    expect(data.length).to be 9
    expect(data[0].values).to eq [11, -2, 1.3]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11, -2, 1.3]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 1, 0)
    expect(data[2].values).to eq [10,  -5,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 2, 0)
    expect(data[3].values).to eq [12,  -4,  0]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 0, 14, 0)
    expect(data[4].values).to eq [11,  -3,  1.6]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[5].values).to eq [4,  -3,  1.1]
    expect(data[5].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[6].values).to eq [18,  -11,  1.9]
    expect(data[6].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[7].values).to eq [11,  -13,  1.2]
    expect(data[7].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)
    expect(data[8].values).to eq [2, -11, 1.5]
    expect(data[8].timestamp).to eq Time.utc(2015, 4, 2, 0,  0, 0)

    data = fetch_data(:fifteen_minutes)
    expect(data.length).to be 6
    expect(data[0].values).to eq [11, -3, 1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0,  0, 0)
    expect(data[1].values).to eq [11,  -3,  1.6]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 15, 0)
    expect(data[2].values).to eq [4,  -3,  1.1]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[3].values).to eq [18,  -11,  1.9]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[4].values).to eq [11,  -13,  1.2]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)
    expect(data[5].values).to eq [2, -11, 1.5]
    expect(data[5].timestamp).to eq Time.utc(2015, 4, 2, 0,  0, 0)

    data = fetch_data(:thirty_minutes)
    expect(data.length).to be 5
    expect(data[0].values).to eq [11, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [4,  -3,  1.1]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 0, 30, 0)
    expect(data[2].values).to eq [18,  -11,  1.9]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[3].values).to eq [11,  -13,  1.2]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)
    expect(data[4].values).to eq [2, -11, 1.5]
    expect(data[4].timestamp).to eq Time.utc(2015, 4, 2, 0,  0, 0)

    data = fetch_data(:one_hour)
    expect(data.length).to be 4
    expect(data[0].values).to eq [10, -3, 1.1]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [18,  -11,  1.9]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 1,  0, 0)
    expect(data[2].values).to eq [11,  -13,  1.2]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)
    expect(data[3].values).to eq [2, -11, 1.5]
    expect(data[3].timestamp).to eq Time.utc(2015, 4, 2, 0,  0, 0)

    data = fetch_data(:six_hours)
    expect(data.length).to be 3
    expect(data[0].values).to eq [11, -4, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [11,  -13,  1.2]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 1, 6,  0, 0)
    expect(data[2].values).to eq [2, -11, 1.5]
    expect(data[2].timestamp).to eq Time.utc(2015, 4, 2, 0,  0, 0)

    data = fetch_data(:one_day)
    expect(data.length).to be 2
    expect(data[0].values).to eq [11, -5, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
    expect(data[1].values).to eq [2, -11, 1.5]
    expect(data[1].timestamp).to eq Time.utc(2015, 4, 2, 0,  0, 0)
  end

  it 'nilのデータは集計対象から除外される' do
    @graph << [10, -1,  1.2]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 0, 0))

    @graph << [12, nil, nil]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 0, 1))

    @graph << [11, -2]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 0, 2))

    @graph << [11, -2, -3]
    @graph.save_data(Time.utc(2015, 4, 1, 0, 1, 0))

    data = fetch_data(:one_minute)
    expect(data.length).to be 1
    expect(data[0].values).to eq [11, -1.5, 1.2]
    expect(data[0].timestamp).to eq Time.utc(2015, 4, 1, 0, 0, 0)
  end

  def fetch_data(interval)
    @graph.fetch_data(Time.new(2015, 1, 1), Time.new(2016, 1, 1), interval)
      .sort_by { |i| i.timestamp }
  end
end
