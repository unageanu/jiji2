# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class UserSettingService < Jiji::Web::AuthenticationRequiredService

    get '/mailaddress' do
      ok(setting.mail_address)
    end

    put '/mailaddress' do
      body = load_body
      setting.mail_address = body['mail_address']
      setting.save
      no_content
    end

    put '/password' do
      body = load_body
      if authenticator.validate_password(body['old_password'])
        setting.password = body['password']
        setting.save
        no_content
      else
        auth_failed
      end
    end

    def setting
      lookup(:security_setting)
    end

    def authenticator
      lookup(:authenticator)
    end

  end
end
