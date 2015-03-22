# coding: utf-8

module Jiji::Composing::Configurators
  class WebConfigurator < AbstractConfigurator

    include Jiji::Web

    def configure(container)
      container.configure do
        object :echo_service,               EchoService.new

        object :initial_setting_service,    InitialSettingService.new
        object :rmt_broker_setting_service, RMTBrokerSettingService.new
        object :security_setting_service,   SecuritySettingService.new
      end
    end

  end
end
