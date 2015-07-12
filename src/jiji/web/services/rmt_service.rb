# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class RMTService < Jiji::Web::AuthenticationRequiredService

    options '/account' do
      allow('GET,OPTIONS')
    end

    get '/account' do
      result = invoke_on_rmt_process do |trading_context, _queue|
        trading_context.broker.account
      end
      ok(result)
    end

    options '/agents' do
      allow('GET,PUT,OPTIONS')
    end

    get '/agents' do
      ok(rmt_setting.agent_setting)
    end

    put '/agents' do
      agent_setting = load_body
      result = invoke_on_rmt_process do |_trading_context, _queue|
        rmt.update_agent_setting(agent_setting)
      end
      ok(result)
    end

    def rmt_setting
      lookup(:setting_repository).rmt_setting
    end

  end
end
