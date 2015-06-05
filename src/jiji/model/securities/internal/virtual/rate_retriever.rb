# coding: utf-8

require 'oanda_api'

module Jiji::Model::Securities::Internal::Virtual
  module RateRetriever
    include Jiji::Errors
    include Jiji::Model::Trading

    def init_rate_retriever_state(start_time, end_time, pairs)
      check_period(start_time, end_time)
      @current_time = @start_time = start_time
      @end_time = end_time
      @buffer   = []
      @pairs    = pairs
    end

    def retrieve_pairs
      @pairs
    end

    def retrieve_current_tick
      fill_buffer if @buffer.empty?
      @current_tick = @buffer.shift
      update_orders(@current_tick)

      @current_tick
    end

    def retrieve_tick_history(pair_name, start_time, end_time)
      unsupported
    end

    def retrieve_rate_history(pair_name, interval, start_time, end_time)
      unsupported
    end

    def next?
      fill_buffer if @buffer.empty?
      !@buffer.empty?
    end

    private

    def fill_buffer
      load_next_ticks while @buffer.empty? && @current_time < @end_time
    end

    def load_next_ticks
      start_time  = @current_time
      next_period = @current_time + (60 * 60 * 2)
      end_time    = @end_time > next_period ? next_period : @end_time
      @buffer += @tick_repository.fetch(@pairs, start_time, end_time)

      @current_time = end_time
    end

    def check_period(start_time, end_time)
      if !start_time || !end_time || start_time >= end_time
        illegal_argument('illegal period.',
          start_time: start_time, end_time: end_time)
      end
    end
  end
end
