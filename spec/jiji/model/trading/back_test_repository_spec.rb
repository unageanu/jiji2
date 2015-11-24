# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::BackTestRepository do
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

  it 'テストを追加できる' do
    expect(@repository.all.length).to be 0

    test = @repository.register({
      'name'          => 'テスト',
      'start_time'    => Time.at(100),
      'end_time'      => Time.at(200),
      'memo'          => 'メモ',
      'pair_names'    => [:EURJPY, :EURUSD],
      'agent_setting' => [
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト1',
          properties:  { 'a' => 1, 'b' => 'bb' }
        },
        {
          agent_class: 'TestAgent1@aaa',
          agent_name:  'テスト2',
          properties:  {}
        },
        {
          agent_class: 'TestAgent2@bbb'
        }
      ]
    })

    expect(test.name).to eq 'テスト'
    expect(test.memo).to eq 'メモ'
    expect(test.start_time).to eq Time.at(100)
    expect(test.end_time).to eq Time.at(200)
    expect(test.cancelled_state).to eq nil
    expect(test.pair_names).to eq [:EURJPY, :EURUSD]
    expect(test.balance).to eq 0

    agent_settings = load_agent_settings(test.id)
    expect(agent_settings.length).to be 3

    expect(agent_settings[0].id).not_to be nil
    expect(agent_settings[0].agent_class).to eq 'TestAgent2@bbb'
    expect(agent_settings[0].name).to eq nil
    expect(agent_settings[0].properties).to eq({})
    agent = test.agents[agent_settings[0].id]
    expect(agent.agent_name).to eq 'TestAgent2@bbb'
    expect(agent.broker.agent.id).to eq agent_settings[0].id

    expect(agent_settings[1].id).not_to be nil
    expect(agent_settings[1].agent_class).to eq 'TestAgent1@aaa'
    expect(agent_settings[1].name).to eq 'テスト1'
    expect(agent_settings[1].properties).to eq({ 'a' => 1, 'b' => 'bb' })
    agent = test.agents[agent_settings[1].id]
    expect(agent.agent_name).to eq 'テスト1'
    expect(agent.broker.agent.id).to eq agent_settings[1].id

    expect(agent_settings[2].id).not_to be nil
    expect(agent_settings[2].agent_class).to eq 'TestAgent1@aaa'
    expect(agent_settings[2].name).to eq 'テスト2'
    expect(agent_settings[2].properties).to eq({})
    agent = test.agents[agent_settings[2].id]
    expect(agent.agent_name).to eq 'テスト2'
    expect(agent.broker.agent.id).to eq agent_settings[2].id

    expect(test.status).to eq :running

    expect(@repository.all.length).to be 1
    expect(@repository.all[0]).to be test

    test2 = @repository.register({
      'name'          => 'テスト2',
      'start_time'    => Time.at(100),
      'end_time'      => Time.at(300),
      'pair_names'    => [:EURJPY, :EURUSD],
      'balance'       => 10_000,
      'agent_setting' => [
        {
          agent_class: 'TestAgent1@aaa',
          properties:  { 'a' => 1, 'b' => 'bb' }
        }
      ]
    })

    expect(test2.name).to eq 'テスト2'
    expect(test2.memo).to eq nil
    expect(test2.start_time).to eq Time.at(100)
    expect(test2.end_time).to eq Time.at(300)
    expect(test2.cancelled_state).to eq nil
    expect(test2.pair_names).to eq [:EURJPY, :EURUSD]
    expect(test2.balance).to eq 10_000

    agent_settings = load_agent_settings(test2.id)
    expect(agent_settings.length).to be 1
    expect(agent_settings[0].id).not_to be nil
    expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
    expect(agent_settings[0].name).to eq nil
    expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'bb' })
    agent = test2.agents[agent_settings[0].id]
    expect(agent.agent_name).to eq 'TestAgent1@aaa'
    expect(agent.broker.agent.id).to eq agent_settings[0].id

    expect(test2.status).to eq :running

    expect(@repository.all.length).to be 2
    expect(@repository.all[0]).to be test
    expect(@repository.all[1]).to be test2
  end

  context 'テストが3つ登録されている場合' do
    before(:example) do
      3.times do |i|
        @time_source.set(Time.at(i))

        @repository.register({
          'name'          => "テスト#{i}",
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(2000),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              agent_name:  'テスト1',
              properties:  { 'a' => 1, 'b' => 'b' }
            }
          ]
        })
      end
    end

    it '追加したテストは永続化され、再起動時に読み込まれる' do
      expect(@repository.all.length).to be 3
      test = @repository.all[0]

      sleep 0.5

      expect(test.name).to eq 'テスト0'
      expect(test.created_at).to eq Time.at(0)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state).to eq nil
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :running
      expect(status[:progress]).to be > 0
      expect(status[:current_time]).to be > Time.at(100)
      prev_status = status

      test = @repository.all[1]
      expect(test.name).to eq 'テスト1'
      expect(test.created_at).to eq Time.at(1)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state).to eq nil
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      test = @repository.all[2]
      expect(test.name).to eq 'テスト2'
      expect(test.created_at).to eq Time.at(2)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state).to eq nil
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      @repository.stop

      @container    = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = @container.lookup(:backtest_repository)
      @repository.load

      expect(@repository.all.length).to be 3

      sleep 0.1

      test = @repository.all[0]
      expect(test.name).to eq 'テスト0'
      expect(test.created_at).to eq Time.at(0)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state[:cancelled_time]).to be > Time.at(100)
      expect(test.cancelled_state[:balance]).not_to be nil
      expect(test.cancelled_state[:orders]).to eq []
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :running
      expect(status[:progress]).to be > prev_status[:progress]
      expect(status[:current_time]).to be > prev_status[:current_time]
      prev_status = status

      test = @repository.all[1]
      expect(test.name).to eq 'テスト1'
      expect(test.created_at).to eq Time.at(1)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state).to eq nil
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      test = @repository.all[2]
      expect(test.name).to eq 'テスト2'
      expect(test.created_at).to eq Time.at(2)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state).to eq nil
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      sleep 0.1 until @repository.all[0].process.finished?
      status = @repository.all[0].retrieve_status_from_context
      expect(status[:status]).to eq :finished
      expect(status[:progress]).to be > prev_status[:progress]
      expect(status[:current_time]).to be > prev_status[:current_time]

      @repository.stop

      @container    = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = @container.lookup(:backtest_repository)
      @repository.load

      expect(@repository.all.length).to be 3

      test = @repository.all[0]
      expect(test.name).to eq 'テスト0'
      expect(test.created_at).to eq Time.at(0)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state[:cancelled_time]).to be > Time.at(100)
      expect(test.cancelled_state[:balance]).not_to be nil
      expect(test.cancelled_state[:orders]).to eq []
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :finished
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      test = @repository.all[1]
      expect(test.name).to eq 'テスト1'
      expect(test.created_at).to eq Time.at(1)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state[:cancelled_time]).to be > Time.at(100)
      expect(test.cancelled_state[:balance]).not_to be nil
      expect(test.cancelled_state[:orders]).to eq []
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :running
      expect(status[:progress]).to be > 0
      expect(status[:current_time]).to be > Time.at(100)
      prev_status = status

      test = @repository.all[2]
      expect(test.name).to eq 'テスト2'
      expect(test.created_at).to eq Time.at(2)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state).to eq nil
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      sleep 0.1 until @repository.all[1].process.finished?
      status = @repository.all[1].retrieve_status_from_context
      expect(status[:status]).to eq :finished
      expect(status[:progress]).to be > prev_status[:progress]
      expect(status[:current_time]).to be > prev_status[:current_time]

      @repository.stop

      @container    = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = @container.lookup(:backtest_repository)
      @repository.load

      expect(@repository.all.length).to be 3

      test = @repository.all[0]
      expect(test.name).to eq 'テスト0'
      expect(test.created_at).to eq Time.at(0)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state[:cancelled_time]).to be > Time.at(100)
      expect(test.cancelled_state[:balance]).not_to be nil
      expect(test.cancelled_state[:orders]).to eq []
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :finished
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      test = @repository.all[1]
      expect(test.name).to eq 'テスト1'
      expect(test.created_at).to eq Time.at(1)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state[:cancelled_time]).to be > Time.at(100)
      expect(test.cancelled_state[:balance]).not_to be nil
      expect(test.cancelled_state[:orders]).to eq []
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :finished
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :wait_for_start
      expect(status[:progress]).to eq nil
      expect(status[:current_time]).to eq nil

      test = @repository.all[2]
      expect(test.name).to eq 'テスト2'
      expect(test.created_at).to eq Time.at(2)
      expect(test.start_time).to eq Time.at(100)
      expect(test.end_time).to eq Time.at(2000)
      expect(test.cancelled_state[:cancelled_time]).to be > Time.at(100)
      expect(test.cancelled_state[:balance]).not_to be nil
      expect(test.cancelled_state[:orders]).to eq []
      expect(test.pair_names).to eq [:EURJPY, :EURUSD]
      agent_settings = load_agent_settings(test.id)
      expect(agent_settings.length).to be 1
      expect(agent_settings[0].id).not_to be nil
      expect(agent_settings[0].agent_class).to eq 'TestAgent1@aaa'
      expect(agent_settings[0].name).to eq 'テスト1'
      expect(agent_settings[0].properties).to eq({ 'a' => 1, 'b' => 'b' })
      agent = test.agents[agent_settings[0].id]
      expect(agent.agent_name).to eq 'テスト1'
      expect(agent.broker.agent.id).to eq agent_settings[0].id
      expect(test.status).to eq :running
      status = test.retrieve_status_from_context
      expect(status[:status]).to eq :running
      expect(status[:progress]).to be > 0
      expect(status[:current_time]).to be > Time.at(100)
    end

    it 'テストで利用しているエージェントが削除されていた場合も、正しく起動できる' do
      @registory.add_source('ccc', '', :agent, data_builder.new_agent_body(3))
      @repository.register({
        'name'          => 'テスト10',
        'start_time'    => Time.at(100),
        'end_time'      => Time.at(2000),
        'memo'          => 'メモ',
        'pair_names'    => [:EURJPY, :EURUSD],
        'balance'       => 100_000,
        'agent_setting' => [
          { agent_class: 'TestAgent3@ccc', properties: {} }
        ]
      })

      @registory.remove_source('ccc')
      @repository.stop

      @container    = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = @container.lookup(:backtest_repository)
      @repository.load

      expect(@repository.all.length).to be 4
    end

    describe '#delete' do
      it 'テストを削除できる' do
        backtests = @repository.all
        expect(backtests.length).to be 3
        graph_factory =
          Jiji::Model::Graphing::GraphFactory.new(backtests[1])
        graph = graph_factory.create(
          'test1', :rate, :first, ['#333', '#666', '#999'])

        graph << [10, 11, 12]
        time = Time.new(2015, 4, 1)
        graph.save_data(time)

        graph << [20, 21, 22]
        time = Time.new(2015, 4, 1, 0, 1, 0)
        graph.save_data(time)

        graph_repository = @container.lookup(:graph_repository)
        graphs = graph_repository.find(backtests[1].id)
        expect(graphs.length).to be > 0

        graph = graphs[0]
        graph_data = graph.fetch_data(
          Time.new(2015, 4, 1),
          Time.new(2015, 4, 2))
        expect(graph_data.length).to be 1

        position_repository = @container.lookup(:position_repository)
        data_builder.new_position(1, backtests[1]).save
        data_builder.new_position(2, backtests[1]).save
        positions = position_repository.retrieve_positions(backtests[1].id)
        expect(positions.length).to be > 0

        data = Jiji::Model::Logging::LogData.create(
          Time.at(100), nil, backtests[1].id)
        data << 'test'
        data.save
        count = Jiji::Model::Logging::LogData
                .where({ backtest_id: backtests[1].id }).count
        expect(count).to be 1

        notification = Jiji::Model::Notification::Notification.create(
          'a', Time.at(100), backtests[1].id)
        notification.save
        count = Jiji::Model::Notification::Notification
                .where({ backtest_id: backtests[1].id }).count
        expect(count).to be 1

        @repository.delete(backtests[1].id)

        graph_data = graph.fetch_data(
          Time.new(2015, 4, 1),
          Time.new(2015, 4, 2))
        expect(graph_data.length).to be 0

        graphs = graph_repository.find(backtests[1].id)
        expect(graphs.length).to be 0

        positions = position_repository.retrieve_positions(backtests[1].id)
        expect(positions.length).to be 0

        count = Jiji::Model::Logging::LogData
                .where({ backtest_id: backtests[1].id }).count
        expect(count).to be 0

        count = Jiji::Model::Notification::Notification
                .where({ backtest_id: backtests[1].id }).count
        expect(count).to be 0

        backtests = @repository.all.sort_by { |p| p.name }
        expect(backtests.length).to be 2
        expect(backtests[0].name).to eq 'テスト0'
        expect(backtests[1].name).to eq 'テスト2'

        @container    = Jiji::Test::TestContainerFactory.instance.new_container
        @repository   = @container.lookup(:backtest_repository)
        @repository.load

        backtests = @repository.all.sort_by { |p| p.name }
        expect(backtests.length).to be 2
        expect(backtests[0].name).to eq 'テスト0'
        expect(backtests[1].name).to eq 'テスト2'
      end

      it 'システムの再起動後でもテストを削除できる' do
        @repository.stop

        @container    = Jiji::Test::TestContainerFactory.instance.new_container
        @repository   = @container.lookup(:backtest_repository)
        @repository.load

        backtests = @repository.all.sort_by { |p| p.name }
        expect(backtests.length).to be 3

        @repository.delete(backtests[1].id)

        backtests = @repository.all.sort_by { |p| p.name }
        expect(backtests.length).to be 2
        expect(backtests[0].name).to eq 'テスト0'
        expect(backtests[1].name).to eq 'テスト2'
      end
    end

    it '#runnings で実行中のテストを取得できる' do
      expect(@repository.runnings.length).to be > 0
    end

    describe '#collect_backtests_by_id' do
      it 'idsに含まれるテストをまとめて取得できる' do
        all = @repository.all
        tests = @repository.collect_backtests_by_id([all[0].id, all[2].id])
        expect(tests.length).to be 2
        expect(tests[0].id).to eq all[0].id
        expect(tests[1].id).to eq all[2].id
      end

      it '存在しないidが指定されてもエラーにはならない' do
        all = @repository.all
        tests = @repository.collect_backtests_by_id([
          all[0].id,
          'not_found',
          all[2].id
        ])
        expect(tests.length).to be 2
        expect(tests[0].id).to eq all[0].id
        expect(tests[1].id).to eq all[2].id
      end
    end

    it '名前が不正な場合エラーになる' do
      expect do
        @repository.register({
          'name'          => nil,
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect do
        @repository.register({
          'name'          => '',
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect do
        @repository.register({
          'name'          => 'a' * 201,
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect(@repository.all.length).to eq 3
    end

    it 'メモが不正な場合エラーになる' do
      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'a' * 2001,
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect(@repository.all.length).to eq 3
    end

    it '期間が不正な場合エラーになる' do
      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => nil,
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ArgumentError)

      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => Time.at(100),
          'end_time'      => nil,
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ArgumentError)

      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(100),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ArgumentError)

      expect(@repository.all.length).to eq 3
    end

    it '通貨ペアが不正な場合エラーになる' do
      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'pair_names'    => [],
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'balance'       => 100_000,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect(@repository.all.length).to eq 3
    end

    it 'エージェントが1つも登録されていない場合エラー' do
      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 100_000,
          'agent_setting' => []
        })
      end.to raise_exception(ArgumentError)

      expect do
        @repository.register({
          'name'       => '名前',
          'start_time' => Time.at(100),
          'end_time'   => Time.at(200),
          'memo'       => 'メモ',
          'pair_names' => [:EURJPY, :EURUSD],
          'balance'    => 100_000
        })
      end.to raise_exception(ArgumentError)

      expect(@repository.all.length).to eq 3
    end

    it '証拠金が不正な場合エラー' do
      expect do
        @repository.register({
          'name'          => '名前',
          'start_time'    => Time.at(100),
          'end_time'      => Time.at(200),
          'memo'          => 'メモ',
          'pair_names'    => [:EURJPY, :EURUSD],
          'balance'       => 0.001,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect do
        @repository.register({
          'name'       => '名前',
          'start_time' => Time.at(100),
          'end_time'   => Time.at(200),
          'memo'       => 'メモ',
          'pair_names' => [:EURJPY, :EURUSD],
          'balance'    => -1,
          'agent_setting' => [
            {
              agent_class: 'TestAgent1@aaa',
              properties:  { 'a' => 100, 'b' => 'bb' }
            }
          ]
        })
      end.to raise_exception(ActiveModel::StrictValidationFailed)

      expect(@repository.all.length).to eq 3
    end

    it 'stopで全テストを停止できる' do
      @repository.stop
    end
  end

  def load_agent_settings(backtest_id)
    Jiji::Model::Agents::AgentSetting.load(backtest_id).map { |x| x }
  end
end
