# coding: utf-8

module Jiji::Composing::Configurators
  class LoggingConfigurator < AbstractConfigurator

    include Jiji::Db

    def configure(container)
      logger = Logger.new(STDOUT) # TODO
      logger.level = Logger::DEBUG

      container.configure do
        object :logger, logger
      end
    end

  end
end
