# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class LogService < Jiji::Web::AuthenticationRequiredService

    options '/:backtest_id' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id' do
      index     = request['offset']    ? request['offset'].to_i : 0
      id        = get_backtest_id_from_path_param
      ok(retrive_log_data(id, index))
    end

    options '/:backtest_id/count' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id/count' do
      id = get_backtest_id_from_path_param
      ok({ count: get_log(id).count })
    end

    def backtest_repository
      lookup(:backtest_repository)
    end

    def logger_factory
      lookup(:logger_factory)
    end

    def time_source
      lookup(:time_source)
    end

    def retrive_log_data(backtest_id, index)
      log = get_log(backtest_id)
      log.get(index)
    end

    def get_log(backtest_id)
      logger_factory.get_or_create_log(backtest_id)
    end

  end
end
