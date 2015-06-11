# coding: utf-8

require 'thread'
require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Jobs::NotifyNextTickJob do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
  end

  after(:example) do
    @data_builder.clean
  end

  describe Jiji::Model::Trading::Jobs::NotifyNextTickJobForRMT do
    it 'exec で次のtickの処理が行われる' do
      job = Jiji::Model::Trading::Jobs::NotifyNextTickJobForRMT.new
      context = create_trading_context
      queue   = Queue.new

      context.time_source.set(Time.new(2014, 1, 1, 0, 0, 0))
      job.exec(context, queue)

      context.time_source.set(Time.new(2014, 1, 1, 0, 0, 15))
      job.exec(context, queue)

      context.time_source.set(Time.new(2014, 1, 1, 1, 0, 30))
      job.exec(context, queue)

      context.time_source.set(Time.new(2014, 1, 1, 1, 0, 45))
      job.exec(context, queue)

      context.time_source.set(Time.new(2014, 1, 1, 1, 1,  0))
      job.exec(context, queue)
    end
  end

  describe Jiji::Model::Trading::Jobs::NotifyNextTickJobForBackTest do
    it 'exec で次のtickの処理が行われる' do
      job = Jiji::Model::Trading::Jobs::NotifyNextTickJobForBackTest.new
      context = create_trading_context
      queue   = Queue.new

      expect(queue.empty?).to be true

      context.time_source.set(Time.new(2014, 1, 1, 0, 0, 0))
      job.exec(context, queue)

      expect(queue.empty?).to be false

      context.time_source.set(Time.new(2014, 1, 1, 0, 0, 15))
      job.exec(context, queue)

      expect(queue.empty?).to be false

      context.time_source.set(Time.new(2014, 1, 1, 0, 0, 30))
      job.exec(context, queue)

      expect(queue.empty?).to be false

      context.time_source.set(Time.new(2014, 1, 1, 0, 0, 45))
      job.exec(context, queue)

      expect(queue.empty?).to be false

      context.time_source.set(Time.new(2014, 1, 1, 0, 1, 0))
      job.exec(context, queue)

      expect(queue.empty?).to be false
    end
  end

  def create_trading_context
    broker  = double('mock broker')
    allow(broker).to receive(:tick) \
      .at_least(:once) \
      .and_return(@data_builder.new_tick(1))
    allow(broker).to receive(:next?)
      .and_return(true)

    expect(broker).to receive(:refresh).exactly(5).times
    expect(broker).to receive(:refresh_positions).once
    expect(broker).to receive(:refresh_account).once

    @data_builder.new_trading_context(broker)
  end
end
