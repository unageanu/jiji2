# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class RateService < Jiji::Web::AuthenticationRequiredService

    include Jiji::Model::Trading::Internal

    options '/range' do
      allow('GET,OPTIONS')
    end

    get '/range' do
      ok(tick_repository.range)
    end

    options '/:pair_name/:interval' do
      allow('GET,OPTIONS')
    end

    get '/:pair_name/:interval' do
      range = retrieve_range
      pair_name = params['pair_name'].to_sym
      interval  = params['interval'].to_sym
      ok(securities.retrieve_rate_history(pair_name,
        interval, range[:start], range[:end]))
    end

    def pairs
      lookup(:pairs)
    end

    def securities
      lookup(:securities_provider).get
    end

    def tick_repository
      lookup(:tick_repository)
    end

    def retrieve_range
      {
        start: read_time_from(request,'start'),
        end:   read_time_from(request,'end')
      }
    end

  end
end
