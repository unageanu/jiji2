# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class EchoService < Jiji::Web::AbstractService
    get '/' do
      fail Jiji::Errors::UnauthorizedException
    end
  end
end
