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
        LoggingConfigurator.new,
        RpcConfigurator.new
      ]
    end

  end
end
