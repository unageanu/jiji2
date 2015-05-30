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
      { back_test_id: 1, label: 1 },
      { unique: true, name: 'graph_back_test_id_label_index' })
    index(
      { back_test_id: 1, start_time: 1 },
      name: 'graph_back_test_id_start_time_index')
    index(
      { back_test_id: 1, end_time: 1 },
      name: 'graph_back_test_id_end_time_index')

    attr_accessor :values

    def self.get_or_create(label, type, colors, back_test_id = nil)
      graph = Graph.find_by({ back_test_id: back_test_id, label: label })
      return graph if graph

      graph = Graph.new(back_test_id, type, label, colors)
      graph.save
      graph
    end

    def initialize(back_test_id, type, label, colors)
      super()
      self.back_test_id = back_test_id
      self.type         = type
      self.label        = label
      self.colors       = colors

      setup_data_savers
    end

    def <<(values)
      @current_values = values
    end

    def save_data(time)
      return unless @current_values

      @savers.each do |saver|
        saver.save_data_if_required(@current_values, time)
      end
      @current_values = nil

      update_time(time)
    end

    def fetch_data(start_time, end_time, interval = :one_minute)
      GraphData.where(
        :graph_id      => id,
        :interval      => interval,
        :timestamp.gte => start_time,
        :timestamp.lt  => end_time
      )
    end

    private

    def setup_data_savers
      @savers = Jiji::Model::Trading::Intervals.instance.all.map do |i|
        Internal::GraphDataSaver.new(id, i)
      end
    end

    def update_time(now)
      self.start_time = now unless start_time
      self.end_time   = now
      save
    end

  end
end
