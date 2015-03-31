# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Model::Graphing
  class Graph

    include Mongoid::Document

    store_in collection: 'graph'

    field :back_test_id, type: BSON::ObjectId # RMTの場合nil
    field :label,        type: String
    field :type,         type: Symbol
    field :colors,       type: Array
    field :start_time,   type: Time
    field :end_time,     type: Time

    index(
      { back_test_id: 1, start_time: 1 },
      name: 'graph_back_test_id_start_time_index')
    index(
      { back_test_id: 1, end_time: 1 },
      name: 'graph_back_test_id_end_time_index')

    def self.create(label, type, colors, time_source, back_test_id)
      Graph.new(time_source) do |g|
        g.back_test_id = back_test_id
        g.type         = type
        g.label        = label
        g.colors       = colors
      end
    end

    def initialize(time_source, &block)
      @time_source = time_source
      super(&block)
    end

    def <<(values)
      now = @time_source.now
      data = GraphData.create(id, values, now)
      data.save

      update_time(now)
    end

    private

    def update_time(now)
      self.start_time = now unless start_time
      self.end_time   = now
      save
    end

  end
end
