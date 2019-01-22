# frozen_string_literal: true

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class RMTService < Jiji::Web::AuthenticationRequiredService

    options '/account' do
      allow('GET,OPTIONS')
    end

    get '/account' do
      result = invoke_on_rmt_process do |trading_context, _queue|
        h = trading_context.broker.account.to_h
        h[:balance_of_yesterday] = rmt.balance_of_yesterday
        h
      end
      ok(result)
    end

    options '/agents' do
      allow('GET,PUT,OPTIONS')
    end

    get '/agents' do
      ok(rmt.agent_settings)
    end

    put '/agents' do
      agent_setting = load_body.map do |setting|
        setting.each_with_object({}) { |pair, r| r[pair[0].to_sym] = pair[1] }
      end
      result = invoke_on_rmt_process do |_trading_context, _queue|
        rmt.update_agent_setting(agent_setting)
      end
      ok(result)
    end

  end
end
