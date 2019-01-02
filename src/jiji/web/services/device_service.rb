# frozen_string_literal: true

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class DeviceService < Jiji::Web::AuthenticationRequiredService

    include Jiji::Errors

    options '/:uuid' do
      allow('PUT,OPTIONS')
    end

    put '/:uuid' do
      body = load_body.with_indifferent_access
      body[:uuid] = params[:uuid]
      ok(device_register.register(body))
    end

    def device_register
      lookup(:device_register)
    end

  end
end
