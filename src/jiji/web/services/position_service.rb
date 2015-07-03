# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class PositionsService < Jiji::Web::AuthenticationRequiredService

    options '/rmt/exited' do
      allow('DELETE,OPTIONS')
    end

    delete '/rmt/exited' do
      expires = get_time_from_query_param('expires')
      repository.delete_exited_positions_of_rmt(expires)
      no_content
    end

    options '/:backtest_id' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id' do
      period_condition = read_period_filter_condition
      id = get_backtest_id_from_path_param
      if period_condition
        ok(retirieve_backtest_widthin(id, period_condition))
      else
        ok(retirieve_backtest(id))
      end
    end

    options '/:backtest_id/count' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id/count' do
      id = get_backtest_id_from_path_param
      ok({count:repository.count_positions(id)})
    end

    def repository
      lookup(:position_repository)
    end

    def retirieve_backtest_widthin(backtest_id, condition)
      repository.retrieve_positions_within(backtest_id,
        condition[:start_time], condition[:end_time])
    end

    def retirieve_backtest(backtest_id)
      sort_order = get_sort_order_from_query_param('order', 'direction')
      offset     = request['offset'] ? request['offset'].to_i : nil
      limit      = request['limit'] ? request['limit'].to_i : nil
      repository.retrieve_positions(backtest_id, sort_order, offset, limit)
    end

    def read_period_filter_condition
      return {
        start_time: get_time_from_query_param('start'),
        end_time:   get_time_from_query_param('end')
      }
    rescue ArgumentError
      return nil
    end

  end
end
