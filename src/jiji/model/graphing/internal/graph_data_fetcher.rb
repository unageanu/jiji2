# coding: utf-8

require 'jiji/utils/abstract_historical_data_fetcher'

module Jiji::Model::Graphing::Internal
  class GraphDataFetcher < Jiji::Utils::AbstractHistoricalDataFetcher

    include Jiji::Errors

    def fetch(graph_id, start_time, end_time, interval = :one_minute)
      interval = Jiji::Utils::AbstractHistoricalDataFetcher \
                 .resolve_collecting_interval(interval)
      q = fetch_data(graph_id, start_time, end_time)
      q = aggregate_by_interval(q, binding)
      q = convert_results(q, interval)
      q.sort_by { |i| i[:timestamp] }
    end

    private

    def fetch_data(graph_id, start_time, end_time)
      Jiji::Model::Graphing::GraphData.where(
        :graph_id      => graph_id,
        :timestamp.gte => start_time,
        :timestamp.lt  => end_time
      )
    end

    def map_function(context)
      context.local_variable_set('required_values', 'values: this.values')
      MAP_TEMPLATE.result(context)
    end

    def reduce_function(context)
      context.local_variable_set('check', 'values[0].counts')
      context.local_variable_set(
        'default_value', '{counts: [], total: [], timestamp:key}')
      context.local_variable_set('reducer', REDUCER)
      REDUCE_TEMPLATE.result(context)
    end

    def convert_results(q, interval)
      q.map do |fetched_value|
        convert_result(fetched_value, interval)
      end
    end

    def convert_result(fetched_value, interval)
      v = fetched_value['value']
      total  = v['total']  || v['values']
      counts = v['counts'] || []
      timestamp = resolve_timestamp(v, interval)
      {
        values:    convert_values(total, counts),
        timestamp: timestamp
      }
    end

    def convert_values(total, counts)
      result = []
      total.each_index do |i|
        if total[i].nil?
          result[i] = 0
        else
          result[i] = (BigDecimal.new(total[i], 10) / (counts[i] || 1)).to_f
        end
      end
      result
    end

    REDUCER = %{
      for(var j=0;j<item.values.length;j++ ) {
        if (!item.values[j] === undefined ) continue;
        result.counts[j] = result.counts[j]
          ? result.counts[j] + 1 : 1;
        result.total[j]  = result.total[j]
          ? result.total[j] + item.values[j] : item.values[j];
      }
    }

  end
end
