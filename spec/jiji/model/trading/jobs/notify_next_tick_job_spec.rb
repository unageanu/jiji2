# coding: utf-8

require 'thread'
require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Jobs::NotifyNextTickJob do
  include_context 'use data_builder'

  after(:example) do
    Jiji::Utils::BulkWriteOperationSupport.end_transaction
  end

  describe Jiji::Model::Trading::Jobs::NotifyNextTickJobForRMT do
    it 'exec で次のtickの処理が行われる' do
      job = Jiji::Model::Trading::Jobs::NotifyNextTickJobForRMT.new
      context = create_trading_context
      queue   = Queue.new

      job.exec(context, queue)
      job.exec(context, queue)
      job.exec(context, queue)
      job.exec(context, queue)
      job.exec(context, queue)
    end
  end

  describe Jiji::Model::Trading::Jobs::NotifyNextTickJobForBackTest do
    it 'exec で次のtickの処理が行われる' do
      job = Jiji::Model::Trading::Jobs::NotifyNextTickJobForBackTest.new(
        Time.new(2014, 1, 1, 0, 0, 0), Time.new(2014, 1, 1, 0, 1, 0))
      context = create_trading_context
      context.prepare_running
      queue = Queue.new

      expect(queue.empty?).to be true

      queue = Queue.new
      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 0)
      expect(context[:progress]).to eq 0
      expect(queue.empty?).to be false

      queue = Queue.new
      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 15)
      expect(context[:progress]).to eq 0.25
      expect(queue.empty?).to be false

      queue = Queue.new
      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 30)
      expect(context[:progress]).to eq 0.50
      expect(queue.empty?).to be false

      queue = Queue.new
      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 45)
      expect(context[:progress]).to eq 0.75
      expect(queue.empty?).to be false

      queue = Queue.new
      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 1, 0)
      expect(context[:progress]).to eq 1.0
      expect(queue.empty?).to be true
    end

    it 'キャンセルされると、次のjobは登録されない' do
      job = Jiji::Model::Trading::Jobs::NotifyNextTickJobForBackTest.new(
        Time.new(2014, 1, 1, 0, 0, 0), Time.new(2014, 1, 1, 0, 1, 0))
      context = create_trading_context(2, false)
      context.prepare_running
      queue = Queue.new

      expect(queue.empty?).to be true

      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 0)
      expect(context[:progress]).to eq 0
      expect(queue.empty?).to be false

      context.request_cancel

      queue = Queue.new
      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 15)
      expect(context[:progress]).to eq 0.25
      expect(queue.empty?).to be true
    end
  end

  it 'エージェントが空の場合、エラーになる' do
    job = Jiji::Model::Trading::Jobs::NotifyNextTickJobForBackTest.new(
      Time.new(2014, 1, 1, 0, 0, 0), Time.new(2014, 1, 1, 0, 1, 0))
    context = create_trading_context(0, false, [])

    context.prepare_running
    queue = Queue.new

    expect(queue.empty?).to be true

    queue = Queue.new
    expect do
      job.exec(context, queue)
    end.to raise_error 'no agent.'
  end

  def create_trading_context(refresh_count = 5,
    expect_to_refresh_accounts = true, agent_instances = ['dummy'])
    broker = double('mock broker')
    allow(broker).to receive(:tick) \
      .at_least(:once) \
      .and_return(*create_tick_response)
    allow(broker).to receive(:next?)
      .and_return(true, true, true, true, false)
    allow(broker).to receive(:account)
      .and_return(Jiji::Model::Trading::Account.new('a', 10_000, 0.03))

    expect(broker).to receive(:refresh).exactly(refresh_count).times
    if expect_to_refresh_accounts
      expect(broker).to receive(:load_positions).once
      expect(broker).to receive(:refresh_account).once
    end

    agents = double('mock agents')
    allow(agents).to receive(:values) \
      .at_least(:once) \
      .and_return(agent_instances)
    allow(agents).to receive(:next_tick)
    data_builder.new_trading_context(broker, agents)
  end

  def create_tick_response
    [
      data_builder.new_tick(1, Time.new(2014, 1, 1, 0, 0,  0)),
      data_builder.new_tick(1, Time.new(2014, 1, 1, 0, 0,  0)),
      data_builder.new_tick(2, Time.new(2014, 1, 1, 0, 0, 15)),
      data_builder.new_tick(2, Time.new(2014, 1, 1, 0, 0, 15)),
      data_builder.new_tick(3, Time.new(2014, 1, 1, 0, 0, 30)),
      data_builder.new_tick(3, Time.new(2014, 1, 1, 0, 0, 30)),
      data_builder.new_tick(4, Time.new(2014, 1, 1, 0, 0, 45)),
      data_builder.new_tick(4, Time.new(2014, 1, 1, 0, 0, 45)),
      data_builder.new_tick(5, Time.new(2014, 1, 1, 0, 1,  0)),
      data_builder.new_tick(5, Time.new(2014, 1, 1, 0, 1,  0))
    ]
  end
end
