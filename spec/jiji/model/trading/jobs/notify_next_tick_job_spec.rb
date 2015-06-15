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
      queue   = Queue.new

      expect(queue.empty?).to be true

      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 0)
      expect(context[:progress]).to eq 0
      expect(queue.empty?).to be false


      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 15)
      expect(context[:progress]).to eq 0.25
      expect(queue.empty?).to be false


      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 30)
      expect(context[:progress]).to eq 0.50
      expect(queue.empty?).to be false

      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 0, 45)
      expect(context[:progress]).to eq 0.75
      expect(queue.empty?).to be false

      job.exec(context, queue)
      expect(context[:current_time]).to eq Time.new(2014, 1, 1, 0, 1, 0)
      expect(context[:progress]).to eq 1.0
      expect(queue.empty?).to be false
    end
  end

  def create_trading_context
    broker  = double('mock broker')
    allow(broker).to receive(:tick) \
      .at_least(:once) \
      .and_return(
        @data_builder.new_tick(1, Time.new(2014, 1, 1, 0, 0,  0)),
        @data_builder.new_tick(1, Time.new(2014, 1, 1, 0, 0,  0)),
        @data_builder.new_tick(2, Time.new(2014, 1, 1, 0, 0, 15)),
        @data_builder.new_tick(2, Time.new(2014, 1, 1, 0, 0, 15)),
        @data_builder.new_tick(3, Time.new(2014, 1, 1, 0, 0, 30)),
        @data_builder.new_tick(3, Time.new(2014, 1, 1, 0, 0, 30)),
        @data_builder.new_tick(4, Time.new(2014, 1, 1, 0, 0, 45)),
        @data_builder.new_tick(4, Time.new(2014, 1, 1, 0, 0, 45)),
        @data_builder.new_tick(5, Time.new(2014, 1, 1, 0, 1,  0)),
        @data_builder.new_tick(5, Time.new(2014, 1, 1, 0, 1,  0)))
    allow(broker).to receive(:next?)
      .and_return(true)

    expect(broker).to receive(:refresh).exactly(5).times
    expect(broker).to receive(:refresh_positions).once
    expect(broker).to receive(:refresh_account).once

    @data_builder.new_trading_context(broker)
  end
end
