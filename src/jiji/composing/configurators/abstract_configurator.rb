# frozen_string_literal: true

module Jiji::Composing::Configurators
  class AbstractConfigurator

    def configure(container)
      configurators.each do |configurator|
        configurator.configure(container)
      end
    end

  end
end
