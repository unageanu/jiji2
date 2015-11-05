require 'logger'

module Jiji::Utils
  class CompositeLogger < Logger

    attr_accessor :loggers

    def initialize(*loggers)
      super(nil)
      self.loggers = loggers
    end

    def add(severity, message = nil, progname = nil, &block)
      loggers.each { |logger| logger.add(severity, message, progname) }
      true
    end

    def level=(level)
      loggers.each { |logger| logger.level = level }
    end

    def <<(msg)
      loggers.each { |logger| logger << msg }
    end

    def close
      loggers.each { |logger| logger.close }
    end

  end
end
