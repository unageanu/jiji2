# coding: utf-8

module Jiji::Model::Graphing
  class GraphRepository

    def find(back_test_id = nil, start_time = nil, end_time = nil)
      query = { back_test_id: back_test_id }
      query[:end_time.gte]  = start_time if start_time
      query[:start_time.lt] = end_time   if end_time
      Graph.where(query).order_by(:label.asc)
    end

    def delete_backtest_graphs(back_test_id)
      find_by_back_test_id(back_test_id).each do |g|
        GraphData.where(graph_id: g.id).delete
      end
      find_by_back_test_id(back_test_id).delete
    end

    def delete_rmt_graphs(time)
      Graph.where(back_test_id: nil).each do |g|
        GraphData.where({
          :graph_id      => g.id,
          :timestamp.lte => time
        }).delete
      end
    end

    private

    def find_by_back_test_id(back_test_id)
      Graph.where(back_test_id: back_test_id)
    end

  end
end
