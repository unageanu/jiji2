# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class NotificationService < Jiji::Web::AuthenticationRequiredService

    options '/:backtest_id' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id' do
      backtest_id = get_backtest_id_from_path_param
      sort_order = get_sort_order_from_query_param('order', 'direction')
      offset     = request['offset'] ? request['offset'].to_i : nil
      limit      = request['limit']  ? request['limit'].to_i : nil
      notifications = repository.retrieve_notifications(
        backtest_id, sort_order, offset, limit)
      ok(notifications)
    end

    options '/:backtest_id/count' do
      allow('GET,OPTIONS')
    end

    get '/:backtest_id/count' do
      id = get_backtest_id_from_path_param
      ok({ count: repository.count_notifications(id) })
    end

    def repository
      lookup(:notification_repository)
    end

  end
end
