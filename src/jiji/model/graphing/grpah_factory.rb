# coding: utf-8

module Jiji::Model::Graphing
  class GraphFactory

    def initialize(back_test_id = nil)
      @back_test_id = back_test_id
      @graphs = {}
    end

    def create(label, type, *colors)
      return @graphs[label] if @graphs.include?(label)

      graph = Graph.get_or_create(label, type, colors, @back_test_id)
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
