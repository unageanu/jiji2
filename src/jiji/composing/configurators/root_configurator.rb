# coding: utf-8

require 'jiji/composing/configurators/abstract_configurator'

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all('jiji')

module Jiji::Composing::Configurators
  class RootConfigurator < AbstractConfigurator

    def configurators
      [
        InfrastructureConfigurator.new,
        ModelConfigurator.new,
        WebConfigurator.new
      ]
    end

  end
end
