# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/errors/errors'
require 'jiji/web/transport/transportable'

module Jiji::Model::Notification
  class Notificator

    attr_reader :agent, :backtest #:nodoc:

    def initialize(backtest, agent,
      push_notifier, mail_composer, time_source, logger) #:nodoc:
      @backtest      = backtest
      @agent         = agent
      @push_notifier = push_notifier
      @mail_composer = mail_composer
      @time_source   = time_source
      @logger        = logger
    end

    # メールを送信します。
    #
    #  notifier.compose_text_mail('foo@example.com',
    #   'テスト', 'テスト本文', 'jiji@unageanu.net')
    #
    # to:: 送信先メールアドレス
    # title:: メールタイトル
    # body:: メール本文
    # from:: fromアドレス。省略した場合、jiji@unageanu.net が使用されます。
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
      from = Jiji::Messaging::MailComposer::FROM, &block) #:nodoc:
      @mail_composer.compose(to, title, from, &block)
    end

    # Push通知を送信します。
    #
    #  notifier.push_notification('メッセージ')
    #  notifier.push_notification('メッセージ',  [
    #    # アクションは複数指定できます。
    #    # 'label' が、アクションを実行するボタンのラベル、
    #    # 'action'が、ボタンが押されてアクションが実行されたとき、
    #    # Agent#execute_action に渡される識別子になります。
    #    { 'label' => 'アクション1', 'action' => 'action_1' },
    #    { 'label' => 'アクション2', 'action' => 'action_2' }
    #  ])
    #
    # message:: メッセージ
    # action:: アクション。
    #          {:label => 'ラベル', action: => '識別子'} の配列で指定します。
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
      }, @logger)
    end

  end
end
