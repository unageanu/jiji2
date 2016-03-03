# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'encase'
require 'thread'
require 'jiji/utils/composite_logger'

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
      id = backtest ? backtest.id : nil
      @mutex.synchronize do
        log = create_log_if_required(id)
        io  = CompositeIO.new(STDOUT, log)
        @loggers[id] = create_logger(io) unless @loggers[id]
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
      locked = @mutex.try_lock
      @loggers.values.each { |logger| logger.close }
      @loggers = {}
      @logs.values.each { |log| log.close }
      @logs = {}
      @system_logger.close if @system_logger
      @mutex.unlock if locked
    end

    def self.composite_file_logger_if_logdir_setted(logger)
      return logger unless ENV['LOG_DIR']
      Jiji::Utils::CompositeLogger.new(logger, file_logger)
    end
    @@mutext = Mutex.new
    @@file_logger = nil
    def self.file_logger
      @@mutext.synchronize do
        return @@file_logger unless @@file_logger.nil?
        @@file_logger =
          Logger.new(ENV['LOG_DIR'] + '/jiji.log', 10, ENV['LOG_SIZE'].to_i)
        @@file_logger
      end
    end

    private

    def create_log_if_required(id)
      @logs[id] = create_log(id) unless @logs.include? id
      @logs[id]
    end

    def create_logger(io)
      logger = Logger.new(io)
      logger = LoggerFactory.composite_file_logger_if_logdir_setted(logger)
      logger.level = Logger::DEBUG
      logger
    end

    def create_log(id)
      Log.new(time_source, id)
    end

  end
end
