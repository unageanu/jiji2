# coding: utf-8

require 'mail'
require 'encase'

module Jiji::Messaging
  class MailComposer

    FROM   = 'jiji@unageanu.net'
    DOMAIN = 'unageanu.net'

    include Encase
    include Jiji::Errors

    needs :userSettingSMTPServer
    needs :postmarkSMTPServer

    def compose(to, title, &block)
      mail = Mail.new(&block)
      setup_delivery_method(mail)

      mail.to      = to
      mail.from    = FROM
      mail.subject = title
      mail.deliver
    end

    def smtp_server
      return userSettingSMTPServer if userSettingSMTPServer.available?
      return postmarkSMTPServer    if postmarkSMTPServer.available?
      illegal_state('SMTP server is not set.')
    end

    private

    def setup_delivery_method(mail)
      if ENV['RACK_ENV'] =~ /test$/
        mail.delivery_method :test
      else
        mail.delivery_method :smtp, smtp_server.setting
      end
    end

    class SMTPServer

    end

    class PostmarkSMTPServer < SMTPServer

      def available?
        ENV['POSTMARK_SMTP_SERVER'] \
        && ENV['POSTMARK_API_TOKEN'] \
        && ENV['POSTMARK_API_KEY']
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
      needs :mail_composer_setting

      def available?
        mail_composer_setting.smtp_host \
        && mail_composer_setting.smtp_port \
        && mail_composer_setting.user_name \
        && mail_composer_setting.password
      end

      def setting
        {
          address:   mail_composer_setting.smtp_host,
          port:      mail_composer_setting.smtp_port,
          domain:    DOMAIN,
          user_name: mail_composer_setting.user_name,
          password:  mail_composer_setting.password
        }
      end

    end

  end
end
