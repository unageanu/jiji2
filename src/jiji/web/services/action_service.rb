# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class ActionService < Jiji::Web::AuthenticationRequiredService

    include Jiji::Errors

    options '/' do
      allow('POST,OPTIONS')
    end

    post '/' do
      body = load_body
      action_dispatcher.dispatch(
        read_backtest_id_from_body(body), body["agent_id"], body["action"])
      no_content
    end

    def read_backtest_id_from_body(body)
      id_str = body['backtest_id']
      id_str ? BSON::ObjectId.from_string(id_str) : nil
    end

    def action_dispatcher
      lookup(:action_dispatcher)
    end

  end
end
