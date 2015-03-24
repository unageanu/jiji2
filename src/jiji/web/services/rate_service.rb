# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class RateService < Jiji::Web::AuthenticationRequiredService

    include Jiji::Model::Trading::Internal

    delete '/' do
      range = retrieve_range
      tick_repository.delete(range[:start], range[:end])
      Swap.delete(range[:start], range[:end])
      TradingUnit.delete(range[:start], range[:end])
      no_content
    end

    get '/range' do
      ok(tick_repository.range)
    end

    get '/pairs' do
      ok(Jiji::Model::Trading::Pairs.instance.all)
    end

    get '/:pair_name/:interval' do
      range = retrieve_range
      pair_name = params['pair_name'].to_sym
      interval  = params['interval'].to_sym
      ok(fetcher.fetch(pair_name,
        range[:start], range[:end], interval))
    end

    def fetcher
      lookup(:rate_fetcher)
    end

    def tick_repository
      lookup(:tick_repository)
    end

    def retrieve_range
      {
        start: get_time_from_query_param('start'),
        end:   get_time_from_query_param('end')
      }
    end

  end
end
