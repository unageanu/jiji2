# coding: utf-8

module Jiji::Utils
  class AbstractHistoricalDataFetcher

    include Jiji::Errors

    private

    def aggregate_by_interval(q, context)
      q.map_reduce(
        map_function(context),
        reduce_function(context)
      ).out(inline: true)
    end

    MAP_TEMPLATE = ERB.new %{
      function() {
        var partition = Math.floor(
          this.timestamp.getTime() / (<%= interval %>)) * (<%= interval %>);
        emit( partition,{
            <%= required_values %>,
            timestamp:this.timestamp
        });
      }
    }

    REDUCE_TEMPLATE = ERB.new %{
      function(key, values) {
        var result = <%= check %> ? values.shift() : <%= default_value %>;
        for(var i=0;i<values.length;i++ ) {
          var item = values[i];
          <%= reducer %>
        }
        return result;
      }
    }

    def calcurate_partition_start_time(time, interval)
      (time.to_i / (interval / 1000)).floor * (interval / 1000)
    end

    def resolve_timestamp(v, interval)
      if v['timestamp'].is_a?(Time)
        Time.at(calcurate_partition_start_time(v['timestamp'], interval))
      else
        Time.at(v['timestamp'] / 1000)
      end
    end

  end
end
