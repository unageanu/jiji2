# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Graphing
  class GraphData

    include Mongoid::Document

    store_in collection: 'graph-data'
    belongs_to :graph

    field :values,    type: Array
    field :interval,  type: Symbol
    field :timestamp, type: Time

    index(
      { graph_id: 1, interval: 1, timestamp: 1 },
      { name: 'graph-data_id_interval_timestamp_index' })

    def self.create(graph, values, interval, time = Time.now)
      GraphData.new do |d|
        d.graph     = graph
        d.interval  = interval
        d.values    = values
        d.timestamp = time
      end
    end

    def [](index)
      values[index]
    end

  end
end
