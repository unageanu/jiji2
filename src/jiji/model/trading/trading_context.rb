# coding: utf-8

require 'encase'
require 'thread'

module Jiji::Model::Trading
  class TradingContext

    attr_reader :broker
    attr_reader :agents
    attr_reader :status
    attr_reader :logger
    attr_reader :error
    attr_reader :variables
    attr_reader :time_source
    attr_reader :graph_factory

    def initialize(agents, broker, graph_factory, time_source, logger)
      @logger        = logger
      @time_source   = time_source
      @agents        = agents
      @broker        = broker
      @graph_factory = graph_factory
      @status        = :wait_for_start
      @error         = nil
      @variables     = {}

      @mutex = Mutex.new
    end

    def prepare_start
      @mutex.synchronize do
        @status = :wait_for_start
      end
    end

    def prepare_running
      @mutex.synchronize do
        @status = :running if @status == :wait_for_start
      end
    end

    def post_running
      @mutex.synchronize do
        @status = \
        case @status
        when :wait_for_cancel then :cancelled
        when :wait_for_pause  then :paused
        when :wait_for_finish then :finished
        else @status
        end
      end
    end

    def fail(error)
      @mutex.synchronize do
        @status = :error
        @error  = error
      end
    end

    def request_cancel
      @mutex.synchronize do
        @status = :wait_for_cancel
      end
    end

    def request_pause
      @mutex.synchronize do
        @status = :wait_for_pause
      end
    end

    def request_finish
      @mutex.synchronize do
        @status = :wait_for_finish
      end
    end

    def alive?
      @mutex.synchronize do
        @status == :running
      end
    end

    def [](key)
      @mutex.synchronize do
        @variables[key]
      end
    end

    def []=(key, value)
      @mutex.synchronize do
        @variables[key] = value
      end
    end

  end
end
