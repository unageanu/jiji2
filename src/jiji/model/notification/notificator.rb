# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/errors/errors'
require 'jiji/web/transport/transportable'

module Jiji::Model::Notification
  class Notificator

    attr_reader :agent, :backtest

    def initialize(backtest, agent,
      push_notifier, mail_composer, time_source, logger)
      @backtest      = backtest
      @agent         = agent
      @push_notifier = push_notifier
      @mail_composer = mail_composer
      @time_source   = time_source
      @logger        = logger
    end

    def compose_text_mail(to, title, body,
      from = Jiji::Messaging::MailComposer::FROM)
      @mail_composer.compose(to, title, from) do
        text_part do
          content_type 'text/plain; charset=UTF-8'
          body body
        end
      end
    end

    def compose_mail(to, title,
      from = Jiji::Messaging::MailComposer::FROM, &block)
      @mail_composer.compose(to, title, from, &block)
    end

    def push_notification(message = '', actions = [])
      n = Notification.create(@agent,
        @time_source.now, @backtest, message, actions)
      n.save
      @push_notifier.notify({
        title:          message,
        message:        n.title,
        image:          n.agent.icon_id,
        notificationId: n.id.to_s,
        backtestId:     @backtest ? @backtest.id.to_s : nil
        # style: "inbox",
        # summaryText: "他 %n%件",
        # notId: 1
      }, @logger)
    end

  end
end
