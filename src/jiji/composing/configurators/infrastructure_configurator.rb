# coding: utf-8

module Jiji::Composing::Configurators
  class InfrastructureConfigurator < AbstractConfigurator

    def configurators
      [
        DBConfigurator.new,
        MessagingConfigurator.new,
        SecurityConfigurator.new,
        ServicesConfigurator.new,
        UtilsConfigurator.new,
        PluginsConfigurator.new,
        LoggingConfigurator.new
      ]
    end

  end
end
