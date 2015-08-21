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
      future = action_dispatcher.dispatch(
        read_backtest_id_from_body(body),
        BSON::ObjectId.from_string(body['agent_id']), body['action'])
      ok(build_response(future))
    end

    def build_response(future)
      { message: future.value }
    rescue Exception => e # rubocop:disable Lint/RescueException
      illegal_argument(e.to_s)
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
