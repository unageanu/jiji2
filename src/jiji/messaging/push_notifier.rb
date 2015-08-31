# coding: utf-8

require 'encase'

module Jiji::Messaging
  class PushNotifier

    include Encase
    include Jiji::Errors

    needs :setting_repository
    needs :sns_service

    def notify(message, logger)
      Device.all.map do |device|
        publish(device, message, logger)
      end
    end

    private

    def publish(device, message, logger)
      sns_service.publish(device.target_arn,
        create_message(device, message), message[:title] || '')
    rescue Exception => e # rubocop:disable Lint/RescueException
      logger.error(e)
    end

    def create_message(device, message)
      m = message.clone
      insert_server_url_to_icon(device, m)

      {
        default: m[:message],
        GCM:     { data: m }.to_json
      }.to_json
    end

    def insert_server_url_to_icon(device, message)
      return unless message[:icon]
      message[:icon] = "#{device.server_url}/api/icons/#{message[:icon]}"
    end

  end
end
