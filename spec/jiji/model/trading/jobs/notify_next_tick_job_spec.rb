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

      expect(context[:rate_saver]).not_to be nil
      expect(context[:trading_unit_saver]).not_to be nil
      expect(context[:next_save_point]).to eq Time.new(2014, 1, 1, 1, 0, 0)

      context.time_source.set(Time.new(2014, 1, 1, 0, 59, 59))
      job.exec(context, queue)

      expect(context[:rate_saver]).not_to be nil
      expect(context[:trading_unit_saver]).not_to be nil
      expect(context[:next_save_point]).to eq Time.new(2014, 1, 1, 1, 0, 0)

      context.time_source.set(Time.new(2014, 1, 1, 1, 0, 0))
      job.exec(context, queue)

      expect(context[:rate_saver]).not_to be nil
      expect(context[:trading_unit_saver]).not_to be nil
      expect(context[:next_save_point]).to eq Time.new(2014, 1, 1, 2, 0, 0)
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

      context.time_source.set(Time.new(2014, 1, 1, 0, 0, 1))
      job.exec(context, queue)

      expect(queue.empty?).to be false
    end
  end

  def create_trading_context
    @data_builder.new_trading_context
  end
end
