# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class PositionService < Jiji::Web::AuthenticationRequiredService

    options '/rmt' do
      allow( 'GET,OPTIONS')
    end

    get '/rmt' do
      query = get_time_from_query_param
      ok(repository.retrieve_positions(nil, query))
    end


    options '/rmt/exited' do
      allow( 'DELETE,OPTIONS')
    end

    delete '/rmt/exited' do
      expires = get_time_from_query_param('expires')
      repository.delete_exited_positions_of_rmt(expires)
      no_content
    end


    options '/:backtest_id' do
      allow( 'GET,OPTIONS')
    end

    get '/:backtest_id' do
      query = get_time_from_query_param
      ok(repository.retrieve_positions(params['backtest_id'], query))
    end


    def repository
      lookup(:position_repository)
    end

  end
end
