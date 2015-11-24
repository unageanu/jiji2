# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/utils/requires'
require 'jiji/model/trading/restart_examples'

describe 'RMTの停止と再開のテスト' do
  let(:long_sleep_time)  { 7 }
  let(:short_sleep_time) { 5 }

  before(:example) do
    @rmt = container.lookup(:rmt)
    @rmt.setup
    @target = @rmt
    @target_id = nil
  end

  after(:example) do
    @rmt.tear_down
  end

  it_behaves_like '停止と再開ができる'

  def start_trade
    @rmt.update_agent_setting([{
      agent_class: 'RestartTestAgent@restart_test_agent.rb',
      agent_name:  'テスト1',
      properties:  { 'a': 25, 'b': 75 }
    }, {
      agent_class: 'RestartTestAgent@restart_test_agent.rb',
      agent_name:  'テスト2',
      properties:  { a: 40, b: 80 }
    }]).map { |x| x }
  end

  def restart
    @rmt.tear_down
    old_securities = @rmt.rmt_broker.securities_provider.get

    @container = Jiji::Test::TestContainerFactory.instance.new_container
    @action_dispatcher = @container.lookup(:action_dispatcher)
    @rmt               = @container.lookup(:rmt)

    take_over_mock_securities_state(@container, old_securities)
    @rmt.setup
    @target = @rmt
  end

  def take_over_mock_securities_state(container, old)
    provider = container.lookup(:securities_provider)
    factory  = container.lookup(:securities_factory)
    provider.set(factory.create(:MOCK, {
      orders:    old.orders,
      positions: old.positions,
      balance:   old.balance
    }))
  end
end
