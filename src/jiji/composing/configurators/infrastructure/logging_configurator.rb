# frozen_string_literal: true

module Jiji::Composing::Configurators
  class LoggingConfigurator < AbstractConfigurator

    include Jiji::Model::Logging

    def configure(container)
      container.configure do
        object :logger_factory, LoggerFactory.new
      end
    end

  end
end
