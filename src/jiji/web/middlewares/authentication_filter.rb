# coding: utf-8

require 'sinatra/base'
require 'jiji/web/middlewares/base'

module Jiji::Web
  class AuthenticationFilter < Base

    include Jiji::Errors

    before do
      unauthorized unless auth_success?
    end

    private

    def auth_success?
      session_store.valid_token?(extract_token, :user)
    end

    def session_store
      lookup(:session_store)
    end

  end
end
