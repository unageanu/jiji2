# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class PositionService < Jiji::Web::AuthenticationRequiredService
    delete '/rmt/exited' do
      expires = get_time_from_query_param('expires')
      repository.delete_exited_positions_of_rmt(expires)
      no_content
    end

    get '/rmt' do
      query = get_time_from_query_param
      ok(repository.get_positions(nil, query))
    end

    get '/:back_test_id' do
      query = get_time_from_query_param
      ok(repository.get_positions(params['back_test_id'], query))
    end

    def repository
      lookup(:position_repository)
    end
  end
end
