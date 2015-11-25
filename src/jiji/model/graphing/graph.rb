# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/trading/back_test'

module Jiji::Model::Graphing
  class Graph

    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    store_in collection: 'graphs'

    belongs_to :backtest, {
      class_name: 'Jiji::Model::Trading::BackTestProperties'
    }
    has_many :graph_data, {
      class_name: 'Jiji::Model::Graphing::GraphData',
      dependent:  :destroy
    }

    field :label,            type: String
    field :type,             type: Symbol
    field :aggregation_type, type: Symbol
    field :colors,           type: Array
    field :axises,           type: Array
    field :start_time,       type: Time
    field :end_time,         type: Time

    index(
      { backtest_id: 1, label: 1 },
      { unique: true, name: 'graph_backtest_id_label_index' })
    index(
      { backtest_id: 1, start_time: 1 },
      name: 'graph_backtest_id_start_time_index')
    index(
      { backtest_id: 1, end_time: 1 },
      name: 'graph_backtest_id_end_time_index')

    attr_accessor :values #:nodoc:

    def self.get_or_create(label, type,
      colors, axises, aggregation_type = :agerage, backtest = nil) #:nodoc:
      Jiji::Utils::PersistenceUtils.get_or_create(
        proc { Graph.find_by({ backtest: backtest, label: label }) },
        proc do
          graph = Graph.new(backtest, type,
            aggregation_type, label, colors, axises)
          graph.save
          graph
        end)
    end

    def initialize(backtest, type,
      aggregation_type, label, colors, axises) #:nodoc:
      super()
      self.backtest         = backtest
      self.type             = type
      self.aggregation_type = aggregation_type
      self.label            = label
      self.colors           = colors
      self.axises           = axises
    end

    # グラフにデータを追加します。
    #  graph << [10, 20]
    #
    # values:: 値の配列
    def <<(values)
      @current_values = values
    end

    def save_data(time) #:nodoc:
      return unless @current_values

      setup_data_savers unless @savers

      @savers.each do |saver|
        saver.save_data_if_required(@current_values, time)
      end
      @current_values = nil

      update_time(time)
    end

    def fetch_data(start_time, end_time, interval = :one_minute) #:nodoc:
      graph_data.where(
        :interval      => interval,
        :timestamp.gte => start_time,
        :timestamp.lt  => end_time
      )
    end

    def to_h #:nodoc:
      {
        id:               _id,
        label:            label,
        type:             type,
        aggregation_type: aggregation_type,
        colors:           colors,
        axises:           axises,
        start_time:       start_time,
        end_time:         end_time
      }
    end

    private

    def setup_data_savers
      @savers = Jiji::Model::Trading::Intervals.instance.all.map do |i|
        Internal::GraphDataSaver.new(self, i)
      end
    end

    def update_time(now)
      self.start_time = now unless start_time
      self.end_time   = now
      save
    end

  end
end
