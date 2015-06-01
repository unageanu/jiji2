# coding: utf-8

require 'securerandom'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/errors/errors'

module Jiji::Model::Trading::Brokers
  class BackTestBroker < AbstractBroker

    include Jiji::Errors
    include Jiji::Model::Trading::Internal

    attr_reader :start, :end

    def initialize(back_test_id, start_time, end_time,
      pairs, tick_repository, securities_provider)
      super()

      check_period(start_time, end_time)
      @current = @start_time = start_time
      @end_time   = end_time

      @back_test_id = back_test_id
      @pairs        = pairs

      @buffer              = []
      @tick_repository     = tick_repository
      @securities_provider = securities_provider
    end

    def buy(pair_name, units)
      create_position(pair_name, units, :buy, nil)
    end

    def sell(pair_name, units)
      create_position(pair_name, units, :sell, nil)
    end

    def destroy
    end

    def next?
      fill_buffer if @buffer.empty?
      !@buffer.empty?
    end

    def refresh
      @buffer.shift
      super
    end

    private

    def retrieve_pairs
      @securities_provider.get.retrieve_pairs
    end

    def retrieve_tick
      fill_buffer if @buffer.empty?
      @buffer.first
    end

    def check_period(start_time, end_time)
      if !start_time || !end_time || start_time >= end_time
        illegal_argument('illegal period.',
          start_time: start_time, end_time: end_time)
      end
    end

    def fill_buffer
      load_next_ticks while @buffer.empty? && @current < @end_time
    end

    def load_next_ticks
      start_time  = @current
      next_period = @current + (60 * 60 * 2)
      end_time    = @end_time > next_period ? next_period : @end_time
      @buffer += @tick_repository.fetch(@pairs, start_time, end_time)

      @current = end_time
    end

  end
end
