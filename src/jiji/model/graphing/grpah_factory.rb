# coding: utf-8

module Jiji::Model::Graphing
  class GraphFactory

    def initialize(backtest = nil)
      @backtest = backtest
      @graphs = {}
    end

    def create(label, type, aggregation_type, *colors)
      return @graphs[label] if @graphs.include?(label)

      graph = Graph.get_or_create(label,
        type, colors, aggregation_type, @backtest)
      @graphs[label] = graph
      graph
    end

    def create_balance_graph
      create("口座資産", :balance, :last)
    end

    def save_data(time)
      @graphs.values.each do |g|
        g.save_data(time)
      end
    end

  end
end
