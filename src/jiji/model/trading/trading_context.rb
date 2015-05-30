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
    end

    def prepare_running
      @status = :running
    end

    def post_running
      @status = @status == :wait_for_cancel ? :cancelled : :finished
    end

    def fail(error)
      @status = :error
      @error  = error
    end

    def request_cancel
      @status = :wait_for_cancel
    end

    def alive?
      @status == :running
    end

    def [](key)
      @variables[key]
    end

    def []=(key, value)
      @variables[key] = value
    end

  end
end
