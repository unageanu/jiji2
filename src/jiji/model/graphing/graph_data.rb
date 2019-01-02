# frozen_string_literal: true

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/utils/bulk_write_operation_support'

module Jiji::Model::Graphing
  class GraphData

    include Mongoid::Document
    include Jiji::Utils::BulkWriteOperationSupport
    include Jiji::Web::Transport::Transportable

    store_in collection: 'graph_data'
    belongs_to :graph

    field :value,     type: Array
    field :interval,  type: Symbol
    field :timestamp, type: Time

    index(
      { graph_id: 1, interval: 1, timestamp: 1 },
      { name: 'graph-data_id_interval_timestamp_index' })

    def self.create(graph_id, value, interval, time = Time.now)
      GraphData.new do |d|
        d.graph_id  = graph_id
        d.interval  = interval
        d.value     = value
        d.timestamp = time
      end
    end

    def [](index)
      value[index]
    end

    def to_h
      {
        id:        _id,
        graph_id:  graph_id,
        value:     value,
        timestamp: timestamp,
        interval:  interval
      }
    end

  end
end
