# coding: utf-8

module Jiji::Model::Graphing
  class GraphFactory

    def initialize(backtest = nil, saving_interval=60) #:nodoc:
      @backtest = backtest
      @saving_interval = saving_interval
      @graphs = {}
    end

    # グラフを作成します。
    #
    #  @rsi_graph = graph_factory.create('RSI',
    #    :line, :average, ['#666699'], [30, 70])
    #
    # label:: グラフの名前
    # type:: グラフの種類。:rate. :line のいずれかを指定します。
    # aggregation_type:: グラフの集計種別 :average, :first, :last
    #                    のいずれかを指定します。
    # colors:: グラフの色を配列で指定します 例) ["#003344", "#003355"]
    # axises:: 軸ラベルを指定します。 例) [30, 70]
    def create(label, type = :line, aggregation_type = :first,
        colors = [], axises = [])
      return @graphs[label] if @graphs.include?(label)

      graph = Graph.get_or_create(label,
        type, colors, axises, aggregation_type, @backtest)
      graph.setup_data_savers(@saving_interval)
      @graphs[label] = graph
      graph
    end

    def create_balance_graph #:nodoc:
      create('口座資産', :balance, :last)
    end

    def save_data(time) #:nodoc:
      @graphs.values.each do |g|
        g.save_data(time)
      end
    end

  end
end
