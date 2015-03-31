# coding: utf-8

module Jiji::Model::Graphing
  class GraphFactory

    def initialize(time_source, back_test_id = nil)
      @time_source  = time_source
      @back_test_id = back_test_id
    end

    def create(label, type, *colors)
      Graph.create(
        label, type, colors, @time_source, @back_test_id)
    end

  end
end
