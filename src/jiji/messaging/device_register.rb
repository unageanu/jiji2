# frozen_string_literal: true

require 'encase'

module Jiji::Messaging
  class DeviceRegister

    include Encase
    include Jiji::Errors

    needs :setting_repository
    needs :sns_service

    def register(info)
      info[:target_arn] =
        register_target(info[:type].to_sym, info[:device_token])
      Device.get_or_create_from_hash(info)
    end

    private

    def register_target(type, device_token)
      sns_service.register_platform_endpoint(type, device_token)
    end

  end
end
