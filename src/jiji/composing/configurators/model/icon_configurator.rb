# coding: utf-8

module Jiji::Composing::Configurators
  class IconConfigurator < AbstractConfigurator

    include Jiji::Model

    def configure(container)
      container.configure do
        object :icon_repository, Icons::IconRepository.new
      end
    end

  end
end
