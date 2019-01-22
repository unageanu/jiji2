# frozen_string_literal: true

module Jiji::Composing::Configurators
  class NotificationConfigurator < AbstractConfigurator

    include Jiji::Model::Notification

    def configure(container)
      container.configure do
        object :notification_repository,  NotificationRepository.new
        object :action_dispatcher,        ActionDispatcher.new
      end
    end

  end
end
