# frozen_string_literal: true

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
    #
    #  # アクションを指定
    #  notifier.push_notification('メッセージ',  [
    #    # アクションは複数指定できます。
    #    # 'label' が、アクションを実行するボタンのラベル、
    #    # 'action'が、ボタンが押されてアクションが実行されたとき、
    #    # Agent#execute_action に渡される識別子になります。
    #    { 'label' => 'アクション1', 'action' => 'action_1' },
    #    { 'label' => 'アクション2', 'action' => 'action_2' }
    #  ])
    #
    #  # アクションに加えて、追加情報とオプションを指定
    #  notifier.push_notification('メッセージ',  [
    #    { 'label' => 'アクション1', 'action' => 'action_1' },
    #    { 'label' => 'アクション2', 'action' => 'action_2' }
    #  ], "追加情報です", {chart: { pair: :EURJPY }})
    #
    # message:: メッセージ
    # action:: アクション。
    #          <code>{:label => 'ラベル', action: => '識別子'}</code>
    #          の配列で指定します。
    #          省略可。省略した場合、アクションの指定なしとなります。
    # note:: 通知の追加情報。指定した内容を通知の詳細画面で確認できます。
    # options:: 通知のオプション。以下を指定できます。
    #           chart:: 通知画面にチャートを表示したい場合に使用します。
    #                   <code>{chart: {pair: :EURJPY}}</code> のような形で、
    #                   表示する通貨ペアを指定できます。
    def push_notification(
      message = '', actions = [], note = nil, options = nil)
      notification = Notification.create(@agent, @time_source.now,
        @backtest, message, actions, note, options)
      notification.save
      @push_notifier.notify(create_message(message, notification), @logger)
    end

    private

    def create_message(message, notification)
      {
        title:          message,
        message:        notification.title,
        image:          notification.agent.icon_id,
        notificationId: notification.id.to_s,
        backtestId:     @backtest ? @backtest.id.to_s : nil
      }
    end

  end
end
