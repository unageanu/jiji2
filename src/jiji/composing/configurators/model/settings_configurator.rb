# coding: utf-8

module Jiji::Composing::Configurators
  class SettingsConfigurator < AbstractConfigurator

    include Jiji::Model::Settings

    def configure(container)
      container.configure do
        object :mail_composer_setting, MailComposerSetting.load_or_create
        object :security_setting,      SecuritySetting.load_or_create
        object :rmt_broker_setting,    RMTBrokerSetting.load_or_create
      end
    end

  end
end
