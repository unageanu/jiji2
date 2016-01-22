# coding: utf-8

require 'sample_agent_test_configuration'
require 'utils/agent_runner'

describe TrailingStopAgent do
  include_context 'use data_builder'

  let(:runner)    { Utils::AgentRunner.new }

  before(:example) do
    runner.register_agent_file(
      'sample_agents/src/trailing_stop_manager.rb')
    %w(signals moving_average_agent cross).each do |file|
      runner.register_agent_file(
        "/src/jiji/model/agents/builtin_files/#{file}.rb")
    end
  end

  after(:example) do
    runner.shutdown
  end

  it 'エージェントを実行できる' do
    runner.start_backtest([{
      agent_class: 'TrailingStopAgent@trailing_stop_manager.rb',
      agent_name:  'テスト1',
      properties:  { 'warning_limit': '8', 'closing_limit': '10' }
    }, {
      agent_class: 'MovingAverageAgent@moving_average_agent.rb',
      agent_name:  'テスト2',
      properties:  { 'short': '200', 'long': '700' }
    }])

    sleep 0.5

    runner.restart
    test = runner.tests[0]

    sleep 0.2 until test.process.finished?
  end
end
