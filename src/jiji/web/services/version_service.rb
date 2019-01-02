# frozen_string_literal: true

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class VersionService < Jiji::Web::AbstractService

    options '/' do
      allow('GET,OPTIONS')
    end

    get '/' do
      ok(version: Jiji::VERSION)
    end

  end
end
