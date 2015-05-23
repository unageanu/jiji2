# coding: utf-8

module Jiji::Composing::Configurators
  class SecuritiesConfigurator < AbstractConfigurator

    include Jiji::Model

    def configure(container)
      container.configure do
        object :securities_provider,  Securities::SecuritiesProvider.new
        object :securities_factory,   Securities::SecuritiesFactory.new
      end
    end

  end
end
