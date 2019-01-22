# frozen_string_literal: true

module Jiji::Composing::Configurators
  class SettingsConfigurator < AbstractConfigurator

    include Jiji::Model::Settings

    def configure(container)
      container.configure do
        object :setting_repository, SettingRepository.new
      end
    end

  end
end
