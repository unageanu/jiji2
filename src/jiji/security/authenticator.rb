# frozen_string_literal: true

require 'encase'
require 'jiji/errors/errors'
require 'bcrypt'

module Jiji::Security
  class Authenticator

    include Encase
    include Jiji::Errors

    needs :setting_repository
    needs :session_store
    needs :time_source

    def authenticate(password)
      raise AuthFailedException unless validate_password(password)

      session_store.new_session(expiration_date, :user).token
    end

    def validate_password(password)
      hash(password) == security_setting.hashed_password
    end

    private

    def hash(password)
      security_setting.hash(password, security_setting.salt)
    end

    def expiration_date
      time_source.now + security_setting.expiration_days * 60 * 60 * 24
    end

    def security_setting
      setting_repository.security_setting
    end

  end
end
