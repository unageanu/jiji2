# coding: utf-8

module Jiji::Model::Graphing::Internal
  class GraphDataSaver

    def initialize(graph, interval, saving_interval = 60)
      @graph                = graph
      @interval             = interval
      @aggregation_strategy = nil
      @current              = nil

      # 次にデータを永続化するまでの期間
      # デフォルトでは60秒ごとに保存を行う。
      # 0以下の値にすると、定期保存を行わない。
      @saving_interval      = saving_interval
    end

    def save_data_if_required(values, time)
      recreate_graph_data(time) if !@current || time >= @next_recreate_point
      updata(values)
      save_data if @saving_interval > 0 && time >= @next_save_point
    end

    private

    def recreate_graph_data(time)
      @current.save if @current

      time = @interval.calcurate_interval_start_time(time)
      @next_recreate_point = time + (@interval.ms / 1000)
      @next_save_point     = time + @saving_interval
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
      @next_save_point += @saving_interval
    end

  end
end
