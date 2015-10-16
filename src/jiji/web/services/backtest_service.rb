# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'
require 'active_support'
require 'active_support/core_ext'

module Jiji::Web
  class BacktestService < Jiji::Web::AuthenticationRequiredService

    options '/' do
      allow('GET,POST,OPTIONS')
    end
    get '/' do
      ids = request['ids'] ? request['ids'].split(',') : []
      ids = ids.map { |id| BSON::ObjectId.from_string(id) }
      ok(ids.empty? ? repository.all : repository.collect_backtests_by_id(ids))
    end
    post '/' do
      created(repository.register(load_body.with_indifferent_access))
    end

    options '/:backtest_id' do
      allow('GET,DELETE,OPTIONS')
    end
    get '/:backtest_id' do
      id = BSON::ObjectId.from_string(params[:backtest_id])
      ok(repository.get(id))
    end
    delete '/:backtest_id' do
      id = BSON::ObjectId.from_string(params[:backtest_id])
      repository.delete(id)
      no_content
    end

    options '/:backtest_id/account' do
      allow('GET,OPTIONS')
    end
    get '/:backtest_id/account' do
      id = BSON::ObjectId.from_string(params[:backtest_id])
      future = repository.get(id).process.post_exec do |context, _queue|
        context.broker.account
      end
      ok(future.value)
    end

    options '/:backtest_id/agent-settings' do
      allow('GET,OPTIONS')
    end
    get '/:backtest_id/agent-settings' do
      id = BSON::ObjectId.from_string(params[:backtest_id])
      ok(repository.get(id).agent_settings)
    end

    def repository
      lookup(:backtest_repository)
    end

  end
end
