# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class NotificationService < Jiji::Web::AuthenticationRequiredService

    include Jiji::Errors

    options '/' do
      allow('GET,OPTIONS')
    end

    get '/' do
      sort_order = get_sort_order_from_query_param('order', 'direction')
      filter_condition = reaa_filter_condition_from_query_param
      offset     = request['offset'] ? request['offset'].to_i : nil
      limit      = request['limit']  ? request['limit'].to_i : nil
      notifications = repository.retrieve_notifications(
        filter_condition, sort_order, offset, limit)
      ok(notifications)
    end

    options '/count' do
      allow('GET,OPTIONS')
    end

    get '/count' do
      filter_condition = reaa_filter_condition_from_query_param
      ok({ count: repository.count_notifications(filter_condition) })
    end

    options '/:notification_id/read' do
      allow('PUT,OPTIONS')
    end

    put '/:notification_id/read' do
      body = load_body
      illegal_argument('body["read"] must be true.') unless body['read']
      id = BSON::ObjectId.from_string(params[:notification_id])
      notification = repository.get_by_id(id)
      notification.read(time_source.now)
      ok(notification.to_h)
    end

    def reaa_filter_condition_from_query_param
      id_str = request['backtest_id']
      return {} unless id_str
      {
        backtest_id: id_str == 'rmt' ? nil : BSON::ObjectId.from_string(id_str)
      }
    end

    def repository
      lookup(:notification_repository)
    end

    def time_source
      lookup(:time_source)
    end

  end
end
