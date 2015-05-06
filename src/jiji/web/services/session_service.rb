# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class SessionService < Jiji::Web::AbstractService

    delete '/' do
      session_store.invalidate(extract_token)
      no_content
    end

    def session_store
      lookup(:session_store)
    end

  end
end
