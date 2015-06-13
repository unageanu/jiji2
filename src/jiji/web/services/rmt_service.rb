# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class RMTService < Jiji::Web::AuthenticationRequiredService

    get '/account' do
      result = invoke_on_rmt_process do |trading_context, _queue|
        trading_context.broker.account
      end
      ok(result)
    end

  end
end
