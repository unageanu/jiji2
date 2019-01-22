# frozen_string_literal: true

module Jiji::Model::Graphing
  class GraphRepository

    def find(backtest_id = nil, start_time = nil, end_time = nil)
      query = { backtest_id: backtest_id }
      query[:end_time.gte]  = start_time if start_time
      query[:start_time.lt] = end_time   if end_time
      Graph.where(query).order_by(:label.asc)
    end

    def delete_backtest_graphs(backtest_id)
      find_by_backtest_id(backtest_id).destroy
    end

    def delete_rmt_graphs(time)
      Graph.where(backtest_id: nil).each do |g|
        GraphData.where({
          :graph_id => g.id,
          :timestamp.lte => time
        }).destroy
      end
    end

    private

    def find_by_backtest_id(backtest_id)
      Graph.where(backtest_id: backtest_id)
    end

  end
end
