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
      filter_condition = read_filter_condition_from(request)
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
      filter_condition = read_filter_condition_from(request)
      result = {}
      result[:count] = repository.count_notifications(filter_condition)
      if filter_condition.include?(:read_at)
        result[:not_read] = result[:count]
      else
        result[:not_read] = repository.count_notifications(
          filter_condition.merge({ read_at: { '$eq' => nil } }))
      end
      ok(result)
    end

    options '/read' do
      allow('PUT,OPTIONS')
    end

    put '/read' do
      body = load_body
      illegal_argument('body["read"] must be true.') unless body['read']
      condition = { read_at: { '$eq' => nil } }
      load_backtest_id_condition(condition, body)
      now = time_source.now
      repository.retrieve_notifications(condition).each do |notification|
        notification.read(now)
      end
      no_content
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

    def read_filter_condition_from(param)
      condition = {}
      load_backtest_id_condition(condition, param)
      load_status_condition(condition, param)
      condition
    end

    def load_backtest_id_condition(condition, param)
      id_str = param['backtest_id']
      return unless id_str
      condition[:backtest_id] = convert_to_backtest_id(id_str)
    end

    def load_status_condition(condition, param)
      status = param['status']
      return unless status
      condition[:read_at] = { '$eq' => nil } if status == 'not_read'
    end

    def repository
      lookup(:notification_repository)
    end

    def time_source
      lookup(:time_source)
    end

  end
end
