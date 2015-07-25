# coding: utf-8

module Jiji::Composing::Configurators
  class MessagingConfigurator < AbstractConfigurator

    include Jiji::Messaging

    def configure(container)
      container.configure do
        object :mail_composer,         MailComposer.new
        object :user_setting_smtp_server,
          MailComposer::UserSettingSMTPServer.new
        object :postmark_smtp_server,
          MailComposer::PostmarkSMTPServer.new

        object :device_register,    DeviceRegister.new
        object :push_notifier,      PushNotifier.new
      end
    end

  end
end
