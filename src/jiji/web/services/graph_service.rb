# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class GraphService < Jiji::Web::AuthenticationRequiredService

    options '/:backtest_id' do
      allow('GET,OPTIONS')
    end
    get '/:backtest_id' do
      range = retrieve_range
      id = read_backtest_id_from(params, 'backtest_id', true)
      ok(repository.find(id, range[:start], range[:end]).map { |g| g })
    end

    options '/data/:backtest_id/:interval' do
      allow('GET,OPTIONS')
    end
    get '/data/:backtest_id/:interval' do
      range     = retrieve_range
      interval  = params['interval'].to_sym
      id        = read_backtest_id_from(params, 'backtest_id', true)
      graphs    = repository.find(id, range[:start], range[:end])
      response  = graphs.map do |graph|
        data = graph.fetch_data(range[:start], range[:end], interval).map do |d|
          { values: d.value, timestamp: d.timestamp }
        end
        {
          id:   graph._id,
          data: data
        }
      end
      ok(response)
    end

    def repository
      lookup(:graph_repository)
    end

    def retrieve_range
      {
        start: read_time_from(request,'start'),
        end:   read_time_from(request,'end')
      }
    end

  end
end
