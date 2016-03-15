# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class PositionsService < Jiji::Web::AuthenticationRequiredService

    options '/exited-rmt-positions' do
      allow('DELETE,OPTIONS')
    end

    delete '/exited-rmt-positions' do
      expires = read_time_from(request, 'expires')
      repository.delete_exited_positions_of_rmt(expires)
      no_content
    end

    options '/' do
      allow('GET,OPTIONS')
    end

    get '/' do
      period_condition = read_period_filter_condition
      id = read_backtest_id_from(request, 'backtest_id', true)
      if period_condition
        ok(retirieve_positions_widthin(id, period_condition))
      else
        ok(retirieve_positions(id))
      end
    end

    options '/count' do
      allow('GET,OPTIONS')
    end

    get '/count' do
      id = read_backtest_id_from(request, 'backtest_id', true)
      filter = read_filter_condition
      ok({
        count:      repository.count_positions(id, filter),
        not_exited: repository.count_positions(
          id, { status: :live }.merge(filter))
      })
    end

    options '/:position_id' do
      allow('GET,OPTIONS')
    end

    get '/:position_id' do
      id = BSON::ObjectId.from_string(params[:position_id])
      position = repository.get_by_id(id)
      ok(position.to_h)
    end

    def repository
      lookup(:position_repository)
    end

    def retirieve_positions_widthin(backtest_id, condition)
      repository.retrieve_positions_within(backtest_id,
        condition[:start_time], condition[:end_time])
    end

    def retirieve_positions(backtest_id)
      sort_order = read_sort_order_from(request, 'order', 'direction', true)
      offset     = read_integer_from(request, 'offset', true)
      limit      = read_integer_from(request, 'limit',  true)
      repository.retrieve_positions(
        backtest_id, sort_order, offset, limit, read_filter_condition)
    end

    def read_filter_condition
      condition = {}
      condition[:status] = request['status'].to_sym if request['status']
      { 'start' => :entered_at.gte, 'end' => :entered_at.lt }.each do |k, v|
        condition[v] = read_time_from(request, k) if request[k]
      end
      condition
    end

    def read_period_filter_condition
      return {
        start_time: read_time_from(request, 'start'),
        end_time:   read_time_from(request, 'end')
      }
    rescue ArgumentError
      return nil
    end

  end
end
