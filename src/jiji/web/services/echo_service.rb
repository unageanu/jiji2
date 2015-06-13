# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class EchoService < Jiji::Web::AbstractService

    options '/' do
      allow( 'GET,OPTIONS')
    end

    get '/' do
      ok(message: "ok")
    end

  end
end
