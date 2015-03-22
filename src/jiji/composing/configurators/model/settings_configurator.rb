# coding: utf-8

module Jiji::Composing::Configurators
  class SettingsConfigurator < AbstractConfigurator

    include Jiji::Model

    def configure(container)
      container.configure do
        object :security_setting,   Settings::SecuritySetting.load_or_create
        object :rmt_broker_setting, Settings::RMTBrokerSetting.load_or_create
      end
    end

  end
end
