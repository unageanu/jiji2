# frozen_string_literal: true

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class UserSettingService < Jiji::Web::AuthenticationRequiredService

    options '/mailaddress' do
      allow('GET,PUT,OPTIONS')
    end

    get '/mailaddress' do
      ok({ mail_address: security_setting.mail_address })
    end

    put '/mailaddress' do
      body = load_body
      setting = security_setting
      setting.mail_address = body['mail_address']
      setting.save
      no_content
    end

    options '/password' do
      allow('PUT,OPTIONS')
    end

    put '/password' do
      body = load_body
      setting = security_setting
      if authenticator.validate_password(body['old_password'])
        setting.password = body['password']
        setting.save
        no_content
      else
        auth_failed
      end
    end

    def security_setting
      lookup(:setting_repository).security_setting
    end

    def authenticator
      lookup(:authenticator)
    end

  end
end
