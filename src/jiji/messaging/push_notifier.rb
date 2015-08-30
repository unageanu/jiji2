# coding: utf-8

require 'encase'

module Jiji::Messaging
  class PushNotifier

    include Encase
    include Jiji::Errors

    needs :setting_repository
    needs :sns_service

    def notify(subject, message)
      Device.all.map do |device|
        sns_service.publish(device.target_arn, message, subject)
      end
    end

  end
end
