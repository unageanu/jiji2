# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class OneTimeTokenService < Jiji::Web::AuthenticationRequiredService

    options '/file-download-token' do
      allow('GET,OPTIONS')
    end

    get '/file-download-token' do
      session = session_store.new_session(
        expiration_date, :file_download)
      ok(token: session.token)
    end

    def expiration_date
      time_source.now + 10 * 60 # 10 minutes
    end

    def session_store
      lookup(:session_store)
    end

    def time_source
      lookup(:time_source)
    end

  end
end
