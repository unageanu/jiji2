# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::BackTest do
  include_context 'use data_builder'

  before(:example) do
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = @container.lookup(:backtest_repository)
    @time_source  = @container.lookup(:time_source)
    @registory    = @container.lookup(:agent_registry)
    @repository.load

    @registory.add_source('aaa', '', :agent, data_builder.new_agent_body(1))
    @registory.add_source('bbb', '', :agent, data_builder.new_agent_body(2))
  end

  after(:example) do
    @repository.stop
  end

  it 'to_hでハッシュに変換できる' do
    test = @repository.register({
      'name'          => 'テスト',
      'start_time'    => Time.new(2014, 12, 8),
      'end_time'      => Time.new(2014, 12, 9),
      'memo'          => 'メモ',
      'pair_names'    => [:EURJPY, :EURUSD],
      'agent_setting' => [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          properties:  { 'a' => 1, 'b' => 'bb' }
        }, {
          agent_class: 'TestAgent1@aaa',
          properties:  {}
        }, {
          agent_class: 'TestAgent2@bbb'
        }
      ]
    })

    sleep 0.2

    hash = test.to_h
    expect(hash[:name]).to eq 'テスト'
    expect(hash[:memo]).to eq 'メモ'
    expect(hash[:start_time]).to eq Time.new(2014, 12, 8)
    expect(hash[:end_time]).to eq Time.new(2014, 12, 9)
    expect(hash[:pair_names]).to eq [:EURJPY, :EURUSD]
    expect(hash[:balance]).to eq 0
    expect(hash[:status]).to eq :running
    expect(hash[:progress]).to be >= 0
    expect(hash[:current_time]).not_to be nil

    @repository.stop
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = @container.lookup(:backtest_repository)
    @repository.load

    sleep 0.2

    test = @repository.all[0]
    hash = test.to_h
    expect(hash[:name]).to eq 'テスト'
    expect(hash[:memo]).to eq 'メモ'
    expect(hash[:start_time]).to eq Time.new(2014, 12, 8)
    expect(hash[:end_time]).to eq Time.new(2014, 12, 9)
    expect(hash[:pair_names]).to eq [:EURJPY, :EURUSD]
    expect(hash[:balance]).to eq 0
    expect(hash[:status]).to eq :running
    expect(hash[:progress]).to be >= 0
    expect(hash[:current_time]).not_to be nil

    sleep 0.2 until test.process.finished?

    hash = test.to_h
    expect(hash[:name]).to eq 'テスト'
    expect(hash[:memo]).to eq 'メモ'
    expect(hash[:start_time]).to eq Time.new(2014, 12, 8)
    expect(hash[:end_time]).to eq Time.new(2014, 12, 9)
    expect(hash[:pair_names]).to eq [:EURJPY, :EURUSD]
    expect(hash[:balance]).to eq 0
    expect(hash[:status]).to eq :finished
    expect(hash[:progress]).to be >= 0
    expect(hash[:current_time]).not_to be nil
  end
end
