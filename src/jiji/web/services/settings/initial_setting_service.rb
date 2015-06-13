# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class InitialSettingService < Jiji::Web::AbstractService

    options '/initialized' do
      allow( 'GET,OPTIONS')
    end

    get '/initialized' do
      ok(initialized: security_setting.password_setted?)
    end


    options '/mailaddress-and-password' do
      allow( 'PUT,OPTIONS')
    end

    put '/mailaddress-and-password' do
      setting = security_setting
      illegal_state if setting.password_setted?

      body = load_body
      setting.mail_address = body['mail_address']
      setting.password     = body['password']
      setting.save
      no_content
    end


    def security_setting
      lookup(:setting_repository).security_setting
    end

  end
end
