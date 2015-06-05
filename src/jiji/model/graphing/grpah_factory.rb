# coding: utf-8

module Jiji::Model::Graphing
  class GraphFactory

    def initialize(backtest_id = nil)
      @backtest_id = backtest_id
      @graphs = {}
    end

    def create(label, type, *colors)
      return @graphs[label] if @graphs.include?(label)

      graph = Graph.get_or_create(label, type, colors, @backtest_id)
      @graphs[label] = graph
      graph
    end

    def save_data(time)
      @graphs.values.each do |g|
        g.save_data(time)
      end
    end

  end
end
