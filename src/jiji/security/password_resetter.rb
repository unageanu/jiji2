# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'bcrypt'

module Jiji::Security
  class PasswordResetter

    include Encase
    include Jiji::Errors

    MAIL_TITLE = 'パスワードの再設定'

    needs :security_setting
    needs :session_store
    needs :authenticator
    needs :mail_composer
    needs :time_source

    def send_password_resetting_mail(mail_address)
      check_mail_address(mail_address)
      session = session_store.new_session(
        expiration_date, :resetting_password)
      send_mail(security_setting.mail_address, session.token)
    end

    def reset_password(password_reset_token, new_password)
      check_token(password_reset_token)
      change_password(new_password)

      session_store.invalidate_all_sessions
      authenticator.authenticate(new_password)
    end

    private

    def send_mail(mail_address, token)
      mail_composer.compose(mail_address, MAIL_TITLE) do |_mail|
        text_part do
          content_type 'text/plain; charset=UTF-8'
          body "トークン: #{token}"
        end
      end
    end

    def check_mail_address(mail_address)
      registered_mail_address = security_setting.mail_address
      unless registered_mail_address
        illegal_state('mail address is not set.')
      end
      unless mail_address == registered_mail_address
        illegal_argument('mail address is not match.')
      end
    end

    def check_token(token)
      unless session_store.valid_token?(token, :resetting_password)
        illegal_argument(token, token: token)
      end
    end

    def change_password(new_password)
      security_setting.password = new_password
      security_setting.save
    end

    def expiration_date
      time_source.now + 2 * 60 * 60
    end

  end
end
