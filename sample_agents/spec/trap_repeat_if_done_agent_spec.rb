# coding: utf-8

require 'sample_agent_test_configuration'
require 'utils/agent_runner'

describe TrapRepeatIfDoneAgent do
  include_context 'use data_builder'

  let(:runner)    { Utils::AgentRunner.new }

  before(:example) do
    runner.register_agent_file(
      'sample_agents/src/trap_repeat_if_done.rb')
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
      agent_class: 'TrapRepeatIfDoneAgent@trap_repeat_if_done.rb',
      agent_name:  'テスト1',
      properties:  {
        'trap_interval_pips' => '50',
        'trade_units' => '10',
        'profit_pips' => '103',
        'slippage' => '3'
      }
    }])

    sleep 0.5

    runner.restart
    test = runner.tests[0]

    sleep 0.2 until test.process.finished?
  end
end
