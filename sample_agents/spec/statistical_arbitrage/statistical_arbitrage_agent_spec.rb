# coding: utf-8

require 'sample_agent_test_configuration'
require 'utils/agent_runner'

describe StatisticalArbitrageAgent do
  include_context 'use data_builder'

  let(:runner)    { Utils::AgentRunner.new }

  before(:example) do
    runner.register_agent_file(
      'sample_agents/src/statistical_arbitrage_agent.rb')
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
      agent_class: 'StatisticalArbitrageAgent@statistical_arbitrage_agent.rb',
      agent_name:  'テスト1',
      properties:  {
        'pairs' => 'AUD,NZD,CAD',
        'trade_units' => '3000',
        'distance' => '0.5'
      }
    }], Time.new(2015, 12, 8, 0, 0, 0),
      Time.new(2015, 12, 10, 0, 0, 0),
      :one_hour, [:AUDJPY, :NZDJPY, :CADJPY])

    sleep 0.5

    runner.restart
    test = runner.tests[0]

    sleep 0.2 until test.process.finished?
  end
end
