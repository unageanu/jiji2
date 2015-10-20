# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'encase'
require 'thread'

module Jiji::Model::Logging
  class LoggerFactory

    include Encase
    include Jiji::Utils

    needs :time_source

    def initialize
      @mutex  = Mutex.new
      @logs   = {}
      @loggers = {}
    end

    def create(backtest = nil)
      id  = backtest ? backtest.id : nil
      @mutex.synchronize do
        log = create_log_if_required(id)
        @loggers[id] = create_logger(log) unless @loggers[id]
        @loggers[id]
      end
    end

    def create_system_logger
      @mutex.synchronize do
        @system_logger ||= create_logger(STDOUT)
      end
    end

    def get_or_create_log(id)
      @mutex.synchronize do
        create_log_if_required(id)
      end
    end

    def close
      @mutex.synchronize do
        @loggers.values.each { |logger| logger.close }
        @loggers = {}

        @system_logger.close if @system_logger
      end
    end

    private

    def create_log_if_required(id)
      @logs[id] = create_log(id) unless @logs.include? id
      @logs[id]
    end

    def create_logger(io)
      logger = Logger.new(CompositeIO.new(STDOUT, io))
      logger.level = Logger::DEBUG
      logger
    end

    def create_log(id)
      Log.new(time_source, id)
    end

  end
end
