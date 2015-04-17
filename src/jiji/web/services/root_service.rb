# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'
require 'jiji/utils/requires'

module Jiji::Web
  class RootService < Jiji::Web::AbstractService

    get '/' do
      redirect to('/static/html/index.html')
    end

  end
end
