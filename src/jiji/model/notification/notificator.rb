# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/errors/errors'
require 'jiji/web/transport/transportable'

module Jiji::Model::Notification
  class Notificator

    attr_reader :agent_id, :backtest_id, :agent_name

    def initialize(backtest_id, agent_id, agent_name,
      push_notifier, mail_composer, time_source)
      @backtest_id   = backtest_id
      @agent_id      = agent_id
      @agent_name    = agent_name
      @push_notifier = push_notifier
      @mail_composer = mail_composer
      @time_source   = time_source
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

    def push_notification(message = '', icon = '', actions = [])
      n = Notification.create(@agent_id, @agent_name,
        @time_source.now, @backtest_id, message, icon, actions)
      n.save
      @push_notifier.notify(message, message)
    end

  end
end
