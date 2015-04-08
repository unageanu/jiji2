# coding: utf-8

require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class DeviceSetting < AbstractSetting

    field :devices, type: Hash, default: {}

    def initialize
      super
      self.category = :device
    end

    def register(name, type, device_token, target_arn)
      devices[name] = {
        type:         type,
        device_token: device_token,
        target_arn:   target_arn
      }
    end

  end
end
