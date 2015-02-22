# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class AuthenticationService < Jiji::Web::AbstractService
    post '/' do
      token = authenticator.authenticate(load_body['password'])
      created(token: token)
    end

    def authenticator
      lookup(:authenticator)
    end
  end
end
