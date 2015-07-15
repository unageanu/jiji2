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
      @logger = {}
    end

    def create(backtest = nil)
      id  = backtest ? backtest.id : nil
      @mutex.synchronize do
        @logger[id] = create_logger_for(id) unless @logger.include? id
        @logger[id]
      end
    end

    def create_system_logger
      @mutex.synchronize do
        @system_logger ||= create_logger(STDOUT)
      end
    end

    def close
      @mutex.synchronize do
        @logger.values.each { |logger| logger.close }
        @logger = {}
      end
    end

    private

    def create_logger(io)
      logger = Logger.new(io)
      logger.level = Logger::DEBUG
      logger
    end

    def create_logger_for(id)
      create_logger(CompositeIO.new(STDOUT, Log.new(time_source, id)))
    end

  end
end
