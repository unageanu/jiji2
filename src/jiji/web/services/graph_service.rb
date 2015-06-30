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
      id = get_backtest_id_from_path_param
      ok(repository.find(id, range[:start], range[:end]).map { |g| g })
    end

    options '/data/:backtest_id/:interval' do
      allow('GET,OPTIONS')
    end
    get '/data/:backtest_id/:interval' do
      range = retrieve_range
      interval  = params['interval'].to_sym
      id = get_backtest_id_from_path_param
      graphs    = repository.find(id, range[:start], range[:end])
      response  = graphs.each_with_object({}) do |graph, r|
        r[graph.id] = graph.fetch_data(range[:start], range[:end], interval) \
                      .map { |d| d }
      end
      ok(response)
    end

    def repository
      lookup(:graph_repository)
    end

    def retrieve_range
      {
        start: get_time_from_query_param('start'),
        end:   get_time_from_query_param('end')
      }
    end

  end
end
