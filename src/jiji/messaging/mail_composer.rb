# coding: utf-8

require 'mail'
require 'encase'

module Jiji::Messaging
  class MailComposer

    FROM   = 'jiji@unageanu.net'.freeze
    DOMAIN = 'unageanu.net'.freeze

    TEST_MAIL_BODY = <<BODY.freeze
メール送信のテスト用メールです。

----
無料で使えるFXシステムトレードフレームワーク「Jiji」
http://jiji2.unageanu.net
BODY

    include Encase
    include Jiji::Errors

    needs :user_setting_smtp_server
    needs :postmark_smtp_server

    def compose(to, title, from = FROM, server_setting = nil, &block)
      mail = Mail.new(&block)
      setup_delivery_method(mail, server_setting)

      mail.to      = to
      mail.from    = from
      mail.subject = title
      mail.deliver
    end

    def compose_test_mail(to, server_setting = nil)
      compose(to, '[Jiji] テストメール',
        Jiji::Messaging::MailComposer::FROM, server_setting) do
        text_part do
          content_type 'text/plain; charset=UTF-8'
          body TEST_MAIL_BODY
        end
      end
    end

    def smtp_server
      return postmark_smtp_server     if postmark_smtp_server.available?
      return user_setting_smtp_server if user_setting_smtp_server.available?
      illegal_state('SMTP server is not set.')
    end

    private

    def setup_delivery_method(mail, server_setting)
      if ENV['RACK_ENV'] == 'test'
        mail.delivery_method :test
      else
        mail.delivery_method :smtp, server_setting || smtp_server.setting
      end
    end

    class SMTPServer

    end

    class PostmarkSMTPServer < SMTPServer

      def available?
        !ENV['POSTMARK_SMTP_SERVER'].nil? \
        && !ENV['POSTMARK_SMTP_SERVER'].empty? \
        && !ENV['POSTMARK_API_TOKEN'].nil? \
        && !ENV['POSTMARK_API_TOKEN'].empty?
      end

      def setting
        {
          address:   ENV['POSTMARK_SMTP_SERVER'],
          port:      587,
          domain:    DOMAIN,
          user_name: ENV['POSTMARK_API_TOKEN'],
          password:  ENV['POSTMARK_API_TOKEN']
        }
      end

    end

    class UserSettingSMTPServer < SMTPServer

      include Encase

      needs :setting_repository

      def available?
        mail_composer_setting = setting_repository.mail_composer_setting
        !mail_composer_setting.smtp_host.nil? \
        && !mail_composer_setting.smtp_host.empty? \
        && !mail_composer_setting.smtp_port.nil?
      end

      def setting
        mail_composer_setting = setting_repository.mail_composer_setting
        {
          address:   mail_composer_setting.smtp_host,
          port:      mail_composer_setting.smtp_port.to_i,
          domain:    DOMAIN,
          user_name: mail_composer_setting.user_name,
          password:  mail_composer_setting.password
        }
      end

    end

  end
end
