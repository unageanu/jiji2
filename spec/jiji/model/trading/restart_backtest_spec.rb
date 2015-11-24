# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/utils/requires'
require 'jiji/model/trading/restart_examples'

describe 'バックテストの停止と再開のテスト' do
  let(:long_sleep_time)  { 0.5 }
  let(:short_sleep_time) { 0.3 }

  before(:example) do
    @backtest_repository = container.lookup(:backtest_repository)
    @backtest_repository.load
  end

  after(:example) do
    @backtest_repository.stop
  end

  it_behaves_like '停止と再開ができる'

  def start_trade
    @target = @backtest_repository.register({
      'name'          => 'テスト',
      'start_time'    => Time.new(2015, 6, 20, 0,  0, 0),
      'end_time'      => Time.new(2015, 6, 20, 1,  0, 0),
      'memo'          => 'メモ',
      'balance'       => 100_000,
      'pair_names'    => [:USDJPY, :EURJPY],
      'agent_setting' => [
        {
          agent_class: 'RestartTestAgent@restart_test_agent.rb',
          agent_name:  'テスト1',
          properties:  { 'a': 25, 'b': 75 }
        }, {
          agent_class: 'RestartTestAgent@restart_test_agent.rb',
          agent_name:  'テスト2',
          properties:  { a: 40, b: 80 }
        }
      ]
    })
    @target_id = @target.id
  end

  def restart
    @backtest_repository.stop

    @container = Jiji::Test::TestContainerFactory.instance.new_container
    @backtest_repository   = @container.lookup(:backtest_repository)
    @action_dispatcher     = @container.lookup(:action_dispatcher)
    @backtest_repository.load
    @target = @backtest_repository.all[0]
    @target_id = @target.id
  end
end
