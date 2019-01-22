# frozen_string_literal: true

module Jiji::Composing::Configurators
  class InfrastructureConfigurator < AbstractConfigurator

    def configurators
      [
        DBConfigurator.new,
        MessagingConfigurator.new,
        SecurityConfigurator.new,
        ServicesConfigurator.new,
        UtilsConfigurator.new,
        LoggingConfigurator.new
      ]
    end

  end
end
