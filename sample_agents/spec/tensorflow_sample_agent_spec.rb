# coding: utf-8

require 'sample_agent_test_configuration'
require 'utils/agent_runner'

describe TensorFlowSampleAgent do
  include_context 'use data_builder'

  let(:runner)    { Utils::AgentRunner.new }

  before(:example) do
    %w(signals moving_average_agent cross).each do |file|
      runner.register_agent_file(
        "/src/jiji/model/agents/builtin_files/#{file}.rb")
    end
    runner.register_agent_file(
      'sample_agents/src/tensorflow_sample_agent.rb')
  end

  after(:example) do
    runner.shutdown
  end

  it 'エージェントを実行できる' do
    runner.start_backtest([{
      agent_class: 'TensorFlowSampleAgent@tensorflow_sample_agent.rb',
      agent_name:  'テスト1',
      properties:  {
        'exec_mode' => 'collect'
      }
    }], Time.new(2015, 1, 1), Time.new(2016, 1, 1), :six_hours)

    sleep 0.5

    runner.restart
    backtest = runner.tests[0]

    sleep 0.2 until backtest.process.finished?
  end
end
