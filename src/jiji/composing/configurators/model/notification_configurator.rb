# coding: utf-8

module Jiji::Composing::Configurators
  class NotificationConfigurator < AbstractConfigurator

    include Jiji::Model::Notification

    def configure(container)
      container.configure do
        object :notification_repository,  NotificationRepository.new
      end
    end

  end
end
