# coding: utf-8

module Jiji::Composing::Configurators
  class AbstractConfigurator

    def configure(container)
      configurators.each do |configurator|
        configurator.configure(container)
      end
    end

  end
end
