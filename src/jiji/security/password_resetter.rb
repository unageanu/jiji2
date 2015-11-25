# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'bcrypt'

module Jiji::Security
  class PasswordResetter

    include Encase
    include Jiji::Errors

    MAIL_TITLE = '[Jiji] パスワードの再設定'

    needs :setting_repository
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
      mail_body = create_mail_body(token)
      mail_composer.compose(mail_address, MAIL_TITLE) do |_mail|
        text_part do
          content_type 'text/plain; charset=UTF-8'
          body mail_body
        end
      end
    end

    def check_mail_address(mail_address)
      registered_mail_address = security_setting.mail_address
      illegal_state('mail address is not set.') unless registered_mail_address
      unless mail_address == registered_mail_address
        illegal_argument('mail address is not match.')
      end
    end

    def check_token(token)
      unless session_store.valid_token?(token, :resetting_password)
        illegal_argument('invalid token.', token: token)
      end
    end

    def change_password(new_password)
      setting = security_setting
      setting.password = new_password
      setting.save
    end

    def expiration_date
      time_source.now + 2 * 60 * 60
    end

    def security_setting
      setting_repository.security_setting
    end

    private

    def create_mail_body(token)
      <<BODY
  以下のトークンと、新しいパスワードを入力して、パスワードを再設定してください。

  トークン: #{token}

  ----
  無料で使えるFXシステムトレードフレームワーク「Jiji」
  http://jiji2.unageanu.net
BODY
    end

  end
end
