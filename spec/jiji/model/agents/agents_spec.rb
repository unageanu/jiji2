# coding: utf-8

require 'jiji/test/test_configuration'

require 'securerandom'

describe Jiji::Model::Agents::Agents do
  include_context 'use data_builder'
  include_context 'use container'

  let(:agent_source_repository) { container.lookup(:agent_source_repository) }
  let(:agent_registry) { container.lookup(:agent_registry) }
  let(:mail_composer) { container.lookup(:mail_composer) }
  let(:push_notifier) { container.lookup(:push_notifier) }
  let(:time_source)   { container.lookup(:time_source) }
  let(:logger) { Logger.new(STDOUT) }
  let(:components) do
    {
        broker:        :broker,
        graph_factory: :graph_factory,
        logger:        logger,
        push_notifier: push_notifier,
        mail_composer: mail_composer,
        time_source:   time_source
    }
  end

  describe '#next_tick' do
    it '保持しているエージェントにtickを通知できる' do
      agents = Jiji::Model::Agents::Agents.new(nil,
        agent_registry, components, true)

      3.times.each_with_object({}) do |i, _r|
        agent = double("mock agent#{i}")
        expect(agent).to receive(:next_tick)
        agents.agents[i.to_s] = agent
      end

      agents.next_tick(data_builder.new_tick(1))
    end

    it 'fail_on_error=falseの場合、' \
     + 'エージェント内でエラーが発生しても通知は継続される' do
      agents = Jiji::Model::Agents::Agents.new(nil,
        agent_registry, components, false)

      3.times.each_with_object({}) do |i, _r|
        agent = double("mock agent#{i}")
        if i == 2
          expect(agent).to receive(:next_tick).and_raise('test')
        else
          expect(agent).to receive(:next_tick)
        end
        agents.agents[i.to_s] = agent
      end

      agents.next_tick(data_builder.new_tick(1))
    end

    it 'fail_on_error=trueの場合、' \
     + 'エージェント内で発生したエラーが伝播される' do
      agents = Jiji::Model::Agents::Agents.new(nil,
        agent_registry, components, true)
      3.times.each_with_object({}) do |i, _r|
        agent = double("mock agent#{i}")
        if i == 2
          expect(agent).to receive(:next_tick).and_raise('test')
        else
          expect(agent).to receive(:next_tick)
        end
        agents.agents[i.to_s] = agent
      end
      expect do
        agents.next_tick(data_builder.new_tick(1))
      end.to raise_exception
    end
  end

  describe '#save_state' do
    it '保持しているエージェントの状態を収集し、永続化できる' do
      agents = Jiji::Model::Agents::Agents.new(nil,
        agent_registry, components, true)
      agents.save_state
    end
  end
end
