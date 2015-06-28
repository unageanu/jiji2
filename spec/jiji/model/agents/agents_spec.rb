# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'
require 'securerandom'

describe Jiji::Model::Agents::Agents do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container = Jiji::Test::TestContainerFactory.instance.new_container
    @logger    = @container.lookup(:logger)

    @registory    = @container.lookup(:agent_registry)
    @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))

    backtest_repository = @container.lookup(:backtest_repository)
    @backtest1 = @data_builder.register_backtest(1, backtest_repository)
    @backtest2 = @data_builder.register_backtest(2, backtest_repository)
  end

  after(:example) do
    @data_builder.clean
  end

  describe '#get_or_create' do
    it 'idに対応するAgentsを取得できる' do
      agents1 = Jiji::Model::Agents::Agents.new(
        @backtest1.id, {}, @logger)
      agents1.states = { 'a' => 'aaa' }
      agents1.save
      expect(agents1.logger).to be @logger
      expect(agents1.fail_on_error).to be false

      agents2 = Jiji::Model::Agents::Agents.new(
        @backtest2.id, {}, @logger, true)
      agents2.states = { 'b' => 'bbb' }
      agents2.save
      expect(agents2.logger).to be @logger
      expect(agents2.fail_on_error).to be true

      agents = Jiji::Model::Agents::Agents.get_or_create(
        @backtest1.id, @logger)
      expect(agents).not_to be nil
      expect(agents.states).to eq({ 'a' => 'aaa' })
      expect(agents.backtest_id).to eq @backtest1.id
      expect(agents.logger).to be @logger
      expect(agents.fail_on_error).to be false

      agents = Jiji::Model::Agents::Agents.get_or_create(
        @backtest2.id, @logger, true)
      expect(agents).not_to be nil
      expect(agents.states).to eq({ 'b' => 'bbb' })
      expect(agents.backtest_id).to eq @backtest2.id
      expect(agents.logger).to be @logger
      expect(agents.fail_on_error).to be true
    end

    it 'idに対応するAgentsが存在しない場合、新規作成される' do
      agents = Jiji::Model::Agents::Agents.get_or_create(@backtest1.id, @logger)
      expect(agents).not_to be nil
      expect(agents.states).to eq({})
      expect(agents.backtest_id).to eq @backtest1.id
      expect(agents.logger).to be @logger
      expect(agents.fail_on_error).to be false
    end
  end

  describe '#next_tick' do
    it '保持しているエージェントにtickを通知できる' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        expect(agent).to receive(:next_tick)
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger)

      agents.next_tick(@data_builder.new_tick(1))
    end

    it 'fail_on_error=falseの場合、' \
     + 'エージェント内でエラーが発生しても通知は継続される' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        if i == 2
          expect(agent).to receive(:next_tick).and_raise('test')
        else
          expect(agent).to receive(:next_tick)
        end
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger)

      agents.next_tick(@data_builder.new_tick(1))
    end

    it 'fail_on_error=trueの場合、' \
     + 'エージェント内で発生したエラーが伝播される' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        if i == 2
          expect(agent).to receive(:next_tick).and_raise('test')
        else
          expect(agent).to receive(:next_tick)
        end
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger, true)

      expect do
        agents.next_tick(@data_builder.new_tick(1))
      end.to raise_exception
    end
  end

  describe '#save_state' do
    it '保持しているエージェントの状態を収集し、永続化できる' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        expect(agent).to receive(:state).and_return(i)
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger)

      agents.save_state
      expect(agents.states.size).to eq 3

      agents = Jiji::Model::Agents::Agents.get_or_create(nil, @logger)
      expect(agents.states.size).to eq 3
    end

    it 'fail_on_error=falseの場合、' \
     + 'エージェント内でエラーが発生しても保存は継続される' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        if i == 2
          expect(agent).to receive(:state).and_raise('test')
        else
          expect(agent).to receive(:state).and_return(i)
        end
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger)

      agents.save_state
      expect(agents.states.size).to eq 2
    end

    it 'fail_on_error=trueの場合、' \
     + 'エージェント内で発生したエラーが伝播される' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        if i == 2
          expect(agent).to receive(:state).and_raise('test')
        else
          expect(agent).to receive(:state).and_return(i)
        end
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger, true)

      expect do
        agents.save_state
      end.to raise_exception
    end
  end

  describe '#restore_state' do
    it 'エージェントの状態を復元できる' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        expect(agent).to receive(:state).and_return(i)
        expect(agent).to receive(:restore_state).with(i)
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger)
      agents.save_state
      agents.restore_state
    end

    it 'fail_on_error=falseの場合、' \
     + 'エージェント内でエラーが発生しても復元は継続される' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        expect(agent).to receive(:state).and_return(i)
        if i == 2
          expect(agent).to receive(:restore_state).and_raise('test')
        else
          expect(agent).to receive(:restore_state).with(i)
        end
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger)
      agents.save_state
      agents.restore_state
    end

    it 'fail_on_error=trueの場合、' \
     + 'エージェント内で発生したエラーが伝播される' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        expect(agent).to receive(:state).and_return(i)
        if i == 2
          expect(agent).to receive(:restore_state).and_raise('test')
        else
          expect(agent).to receive(:restore_state).with(i)
        end
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger, true)
      agents.save_state
      expect do
        agents.restore_state
      end.to raise_exception
    end

    it '状態が永続化されていない場合、復元はスキップされる' do
      agents = 3.times.each_with_object({}) do |i, r|
        agent = double("mock agent#{i}")
        if i == 2
          expect(agent).to receive(:state).and_raise('test')
        else
          expect(agent).to receive(:state).and_return(i)
          expect(agent).to receive(:restore_state).with(i)
        end
        r[uuid] = agent
      end
      agents = Jiji::Model::Agents::Agents.new(nil, agents, @logger)
      agents.save_state
      agents.restore_state
    end
  end

  def uuid
    SecureRandom.uuid
  end
end
