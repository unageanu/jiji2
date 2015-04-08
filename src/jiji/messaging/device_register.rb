# coding: utf-8

require 'encase'

module Jiji::Messaging
  class DeviceRegister

    include Encase
    include Jiji::Errors

    needs :setting_repository
    needs :sns_service

    def register(name, device_token)
      type = :gcm
      target_arn = register_target(type, device_token)

      device_setting = setting_repository.device_setting
      device_setting.register(name, type, device_token, target_arn)
      device_setting.save
    end

    private

    def register_target(type, device_token)
      sns_service.register_platform_endpoint(type, device_token)
    end

  end
end
