# coding: utf-8

require 'encase'

module Jiji::Model::Notification
  class NotificationRepository

    include Encase
    include Jiji::Errors

    def retrieve_notifications(backtest_id = nil,
      sort_order = { timestamp: :asc, id: :asc },
      offset = 0, limit = 20, filter_conditions = {})
      filter_conditions = { backtest_id: backtest_id }.merge(filter_conditions)
      query = Jiji::Utils::Pagenation::Query.new(
        filter_conditions, sort_order, offset, limit)
      query.execute(Notification).map { |x| x }
    end

    def count_notifications(backtest_id = nil, filter_conditions = {})
      filter_conditions = { backtest_id: backtest_id }.merge(filter_conditions)
      Notification.where(filter_conditions).count
    end

    def delete_notifications_of_rmt(before)
      Notification.where(
        :backtest_id  => nil,
        :timestamp.lt => before
      ).delete
    end

  end
end
