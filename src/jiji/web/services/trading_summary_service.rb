# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class TradingSummaryService < Jiji::Web::AuthenticationRequiredService

    options '/:backtest_id' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id' do
      start_time =  get_time_from_query_param_ignore_error('start')
      end_time   =  get_time_from_query_param_ignore_error('end')
      id = get_backtest_id_from_path_param
      ok(builder.build(id, start_time, end_time))
    end

    def builder
      lookup(:trading_summary_builder)
    end

    def get_time_from_query_param_ignore_error(key)
      get_time_from_query_param(key)
    rescue ArgumentError
      return nil
    end

  end
end
