# coding: utf-8

require 'encase'

module Jiji::Model::Notification
  class NotificationRepository

    include Encase
    include Jiji::Errors

    def get_by_id(notification_id)
      Notification.includes(:agent, :backtest).find(notification_id) \
      || not_found(Notification, id: notification_id)
    end

    def retrieve_notifications(
      filter_conditions = {}, sort_order = {}, offset = 0, limit = 20)
      sort_order = insert_default_sort_order(sort_order)
      query = Jiji::Utils::Pagenation::Query.new(
        filter_conditions, sort_order, offset, limit)
      query.execute(Notification.includes(:agent, :backtest)).map { |x| x }
    end

    def count_notifications(filter_conditions = {})
      Notification.where(filter_conditions).count
    end

    private

    def insert_default_sort_order(sort_order)
      sort_order ||= {}
      sort_order[:timestamp] = :desc unless sort_order.include?(:timestamp)
      sort_order[:id] = :asc unless sort_order.include?(:id)
      sort_order
    end

  end
end
