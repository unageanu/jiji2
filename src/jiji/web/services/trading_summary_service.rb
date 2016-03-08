# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class TradingSummariesService < Jiji::Web::AuthenticationRequiredService

    options '/:backtest_id' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id' do
      start_time =  read_time_from(params, 'start', true)
      end_time   =  read_time_from(params, 'end', true)
      id = read_backtest_id_from(params, 'backtest_id', true)
      ok(builder.build(id, start_time, end_time))
    end

    def builder
      lookup(:trading_summary_builder)
    end

  end
end
