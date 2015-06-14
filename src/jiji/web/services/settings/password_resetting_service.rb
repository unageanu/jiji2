# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class PasswordResettingService < Jiji::Web::AbstractService

    options '/' do
      allow('POST,PUT,OPTIONS')
    end

    post '/' do
      body = load_body
      resetter.send_password_resetting_mail(body['mail_address'])
      no_content
    end

    put '/' do
      body = load_body
      token = resetter.reset_password(
        body['token'], body['new_password'])
      ok(token: token)
    end

    def resetter
      lookup(:password_resetter)
    end

  end
end
