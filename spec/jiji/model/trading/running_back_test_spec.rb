# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::BackTest do
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:container)    { Jiji::Test::TestContainerFactory.instance.new_container }

  let(:backtest_repository) { container.lookup(:backtest_repository) }
  let(:agent_registory)     { container.lookup(:agent_registry) }
  let(:position_repository) { container.lookup(:position_repository) }
  let(:graph_repository)    { container.lookup(:graph_repository) }

  before(:example) do
    backtest_repository.load

    %w(signals agent cross).each do |file|
      source = agent_registory.add_source("#{file}.rb", '', :agent,
        IO.read(File.expand_path("../#{file}.rb", __FILE__)))
      p source.error
    end
  end

  after(:example) do
    backtest_repository.stop
    data_builder.clean
  end

  it 'バックテストを実行できる' do
    test = backtest_repository.register({
      'name'          => 'テスト',
      'start_time'    => Time.new(2015, 6, 20, 0,  0, 0),
      'end_time'      => Time.new(2015, 6, 20, 1,  0, 0),
      'memo'          => 'メモ',
      'pair_names'    => [:USDJPY, :EURUSD],
      'agent_setting' => [
        {
          agent_class: 'MovingAverageAgent@agent.rb',
          agent_name:  'テスト1',
          properties:  { 'short': 25, 'long': 75 }
        }, {
          agent_class: 'MovingAverageAgent@agent.rb',
          agent_name:  'テスト2',
          properties:  { 'short': 40, 'long': 80 }
        }
      ]
    })

    sleep 0.2 until test.process.finished?

    expect(test.retrieve_process_status).to be :finished

    graphs = graph_repository.find(test._id).map { |g| g }
    expect(graphs.length).to be 1
    expect(graphs[0].backtest_id).to eq test._id
    expect(graphs[0].label).to eq '移動平均線'
    expect(graphs[0].colors).to eq ['#779999', '#557777']

    data = graphs[0].fetch_data(
      Time.new(2015, 6, 20, 0,  0, 0),
      Time.new(2015, 6, 20, 1,  0, 0)).map { |d| d }
    expect(data.length).to be > 0

    positions = position_repository.retrieve_positions(
      test._id, { entered_at: :asc }, 0, 10, { agent_name: 'テスト1' })
    expect(positions.length).to be > 0
    positions.each do |position|
      expect(position.agent_name).to eq 'テスト1'
      expect(position.agent_id).not_to be nil
    end

    positions = position_repository.retrieve_positions(
      test._id, { entered_at: :asc }, 0, 10, { agent_name: 'テスト2' })
    expect(positions.length).to be > 0
    positions.each do |position|
      expect(position.agent_name).to eq 'テスト2'
      expect(position.agent_id).not_to be nil
    end
  end

  it 'エラーが発生すると実行がキャンセルされる' do
    test = backtest_repository.register({
      'name'          => 'テスト',
      'start_time'    => Time.new(2015, 6, 20, 0,  0, 0),
      'end_time'      => Time.new(2015, 6, 20, 1,  0, 0),
      'memo'          => 'メモ',
      'pair_names'    => [:USDJPY, :EURUSD],
      'agent_setting' => [
        {
          agent_class: 'ErrorAgent@agent.rb',
          properties:  { 'short': 25, 'long': 75 }
        }
      ]
    })
    test.to_h

    sleep 0.2 until test.process.finished?
    expect(test.retrieve_process_status).to be :error

    expect do
      backtest_repository.register({
        'name'          => 'テスト',
        'start_time'    => Time.new(2015, 6, 20, 0,  0, 0),
        'end_time'      => Time.new(2015, 6, 20, 1,  0, 0),
        'memo'          => 'メモ',
        'pair_names'    => [:USDJPY, :EURUSD],
        'agent_setting' => [
          {
            agent_class: 'ErrorOnCreateAgent@agent.rb'
          }
        ]
      })
    end.to raise_exception

    expect do
      backtest_repository.register({
        'name'          => 'テスト',
        'start_time'    => Time.new(2015, 6, 20, 0,  0, 0),
        'end_time'      => Time.new(2015, 6, 20, 1,  0, 0),
        'memo'          => 'メモ',
        'pair_names'    => [:USDJPY, :EURUSD],
        'agent_setting' => [
          {
            agent_class: 'ErrorOnPostCreateAgent@agent.rb'
          }
        ]
      })
    end.to raise_exception
  end
end
