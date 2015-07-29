# coding: utf-8

module Jiji::Model::Graphing::Internal
  class GraphDataSaver

    def initialize(graph, interval)
      @graph                = graph
      @interval             = interval
      @aggregation_strategy = nil
      @current              = nil
    end

    def save_data_if_required(values, time)
      recreate_graph_data(time) if !@current || time >= @next_recreate_point
      updata(values)
      save_data if time >= @next_save_point
    end

    private

    def recreate_graph_data(time)
      @current.save if @current

      time = @interval.calcurate_interval_start_time(time)
      @next_recreate_point = time + (@interval.ms / 1000)
      @next_save_point     = time + 60
      init_graph_data(time)
      init_agregate_strategy
    end

    def init_graph_data(time)
      @current = Jiji::Model::Graphing::GraphData.create(
        @graph, [], @interval.id, time)
    end

    def init_agregate_strategy
      @aggregation_strategy =
        AggregationStrategies.create(@graph.aggregation_type)
    end

    def updata(values)
      @aggregation_strategy.merge(values)
      @current.value = @aggregation_strategy.calculate
    end

    def save_data
      @current.save
      @next_save_point += 60
    end

  end
end
