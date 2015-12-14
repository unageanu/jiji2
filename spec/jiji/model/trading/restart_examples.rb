# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/utils/requires'

shared_examples '停止と再開ができる' do
  include_context 'use data_builder'
  include_context 'use container'

  before(:example) do
    @container = container
    @action_dispatcher   = @container.lookup(:action_dispatcher)
    @agent_registry      = @container.lookup(:agent_registry)
    %w(restart_test_agent).each do |file|
      f = File.expand_path("../../agents/builtin_files/#{file}.rb", __FILE__)
      source = @agent_registry.add_source("#{file}.rb", '', :agent, IO.read(f))
      p source.error
    end
  end

  after(:example) do
    Mail::TestMailer.deliveries.clear
  end

  it 'トレードを停止/再開できる' do
    start_trade

    account = retrieve_account
    expect(account.balance).to eq 100_000
    expect(account.profit_or_loss).to eq 0
    expect(retrieve_orders).to eq []
    expect(retrieve_positions.size).to eq 0
    state = retrieve_state
    expect(state[:a]).to be >= 25
    expect(state[:b]).to be >= 75
    prev_state = state

    sleep long_sleep_time

    agents = exec(@target) { |context| context.agents }
    agent1_id = agents.keys.find { |id| agents[id].agent_name == 'テスト1' }

    sleep long_sleep_time
    exec_action(agent1_id, 'order')

    account = retrieve_account
    expect(account.balance).to eq 100_000
    expect(account.profit_or_loss).not_to be nil
    orders = retrieve_orders
    expect(orders.size).to eq 3
    positions = retrieve_positions
    expect(positions.size).to eq 2
    state = retrieve_state
    expect(state[:a]).to be > prev_state[:a]
    expect(state[:b]).to be > prev_state[:b]
    prev_state = state

    restart
    sleep long_sleep_time

    account = retrieve_account
    expect(account.balance).to eq 100_000
    expect(account.profit_or_loss).not_to be nil
    check_some_orders(orders, retrieve_orders)
    check_some_positions(positions, retrieve_positions)
    state = retrieve_state
    expect(state[:a]).to be > prev_state[:a]
    expect(state[:b]).to be > 75
    expect(state[:b]).to be < prev_state[:b]
    prev_state = state

    sleep short_sleep_time
    exec_action(agent1_id, 'close')

    account = retrieve_account
    expect(account.balance).not_to eq 100_000
    expect(account.profit_or_loss).to eq 0
    check_some_orders(orders, retrieve_orders)
    expect(retrieve_positions.size).to eq 0
    state = retrieve_state
    expect(state[:a]).to be > prev_state[:a]
    expect(state[:b]).to be > prev_state[:b]
    prev_state = state

    restart

    state = retrieve_state
    expect(state[:a]).to be >= prev_state[:a]
    expect(state[:b]).to be >= 75
    expect(state[:b]).to be < prev_state[:b]

    sleep long_sleep_time

    account = retrieve_account
    expect(account.balance).not_to eq 100_000
    expect(account.profit_or_loss).to eq 0
    check_some_orders(orders, retrieve_orders)
    expect(retrieve_positions.size).to eq 0
    state = retrieve_state
    expect(state[:a]).to be > prev_state[:a]
    expect(state[:b]).to be > 75
    prev_state = state

    sleep short_sleep_time
    exec_action(agent1_id, 'cancel_orders')

    account = retrieve_account
    expect(account.balance).not_to eq 100_000
    expect(account.profit_or_loss).to eq 0
    expect(retrieve_orders.size).to eq 0
    expect(retrieve_positions.size).to eq 0
    state = retrieve_state
    expect(state[:a]).to be > prev_state[:a]
    expect(state[:b]).to be > prev_state[:b]
    prev_state = state

    restart

    state = retrieve_state
    expect(state[:a]).to be >= prev_state[:a]
    expect(state[:b]).to be >= 75
    expect(state[:b]).to be < prev_state[:b]

    sleep long_sleep_time

    account = retrieve_account
    expect(account.balance).not_to eq 100_000
    expect(account.profit_or_loss).to eq 0
    expect(retrieve_orders.size).to eq 0
    expect(retrieve_positions.size).to eq 0
    state = retrieve_state
    expect(state[:a]).to be > prev_state[:a]
    expect(state[:b]).to be > 75
  end

  def check_some_orders(prev, current)
    expect(prev.size).to eq current.size
    prev.each do |a|
      b = current.find { |o| o.internal_id == a.internal_id }
      expect(a).to some_order(b)
    end
  end

  def check_some_positions(prev, current)
    expect(prev.size).to eq current.size
    prev.each do |a|
      b = current.find { |p| p.internal_id == a.internal_id }
      expect(a).to some_position_ignore_current_price(b)
    end
  end

  def retrieve_account
    exec(@target) { |context| context.broker.account }
  end

  def retrieve_orders
    exec(@target) { |context| context.broker.orders }
  end

  def retrieve_positions
    exec(@target) { |context| context.broker.positions }
  end

  def retrieve_state
    exec(@target) do |context|
      agents = context.agents
      agent = agents.values.find { |a| a.agent_name == 'テスト1' }
      { a: agent.a, b: agent.b }
    end
  end

  def exec(test, &block)
    @target.process.post_exec { |context, _queue| block.call(context) }.value
  end

  def exec_action(agent_id, action)
    @action_dispatcher.dispatch(@target_id, agent_id, action).value
  end
end
