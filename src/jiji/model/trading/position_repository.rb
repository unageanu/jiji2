# coding: utf-8

require 'encase'

module Jiji::Model::Trading
  class PositionRepository

    include Encase
    include Jiji::Errors

    def get_by_id(position_id)
      Position.includes(:agent, :backtest).find(position_id) \
      || not_found(Position, id: position_id)
    end

    def retrieve_positions(backtest_id = nil,
      sort_order = { entered_at: :asc, id: :asc },
      offset = 0, limit = 20, filter_conditions = {})
      filter_conditions = { backtest_id: backtest_id }.merge(filter_conditions)
      query = Jiji::Utils::Pagenation::Query.new(
        filter_conditions, sort_order, offset, limit)
      query.execute(Position.includes(:agent, :backtest)).map { |x| x }
    end

    def count_positions(backtest_id = nil, filter_conditions = {})
      filter_conditions = { backtest_id: backtest_id }.merge(filter_conditions)
      Position.where(filter_conditions).count
    end

    def retrieve_positions_within(backtest_id, start_time, end_time)
      base_condition = create_base_condition(backtest_id, end_time)
      Position.or({
        :exited_at.gte => start_time
      }.merge(base_condition), {
        exited_at: nil
      }.merge(base_condition))
        .order_by({ entered_at: :asc, id: :asc }).map { |x| x }
    end

    def retrieve_living_positions(backtest_id = nil)
      query = Jiji::Utils::Pagenation::Query.new(
        { backtest_id: backtest_id, status: :live }, entered_at: :asc)
      query.execute(Position.includes(:agent, :backtest)).map { |x| x }
    end

    def delete_all_positions_of_backtest(backtest_id)
      Position.where(backtest_id: backtest_id).delete
    end

    def delete_closed_positions_of_rmt(exited_before)
      Position.where(
        :backtest_id  => nil,
        :status       => :closed,
        :exited_at.lt => exited_before
      ).delete
      Position.where(
        :backtest_id   => nil,
        :status        => :lost,
        :updated_at.lt => exited_before
      ).delete
    end

    def create_base_condition(backtest_id, end_time)
      {
        :backtest_id   => backtest_id,
        :status.ne     => :lost,
        :entered_at.lt => end_time
      }
    end

  end
end
