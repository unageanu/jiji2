# coding: utf-8

module Jiji::Composing::Configurators
  class ModelConfigurator < AbstractConfigurator

    include Jiji::Model

    def configure(container)
      container.configure do
        object :application, Application.new
      end
      super
    end

    def configurators
      [
        AgentConfigurator.new,
        GraphConfigurator.new,
        SettingsConfigurator.new,
        TradingConfigurator.new
      ]
    end

  end
end
