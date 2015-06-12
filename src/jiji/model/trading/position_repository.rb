# coding: utf-8

require 'encase'

module Jiji::Model::Trading
  class PositionRepository

    include Encase
    include Jiji::Errors

    def retrieve_positions(backtest_id = nil,
      sort_order = { entered_at: :asc, id: :asc }, offset = 0, limit = 20)
      query = Jiji::Utils::Pagenation::Query.new(
        { backtest_id: backtest_id }, sort_order, offset, limit)
      query.execute(Position).map { |x| x }
    end

    def retrieve_living_positions_of_rmt
      query = Jiji::Utils::Pagenation::Query.new(
        { backtest_id: nil, status: :live }, entered_at: :asc)
      query.execute(Position).map { |x| x }
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

  end
end
