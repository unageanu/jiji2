# coding: utf-8

module Jiji::Model::Trading::Internal
  class RateFetcher

    def fetch(pair_name, start_time, end_time, interval = :one_minute)
      pair = Jiji::Model::Trading::Pairs.instance.create_or_get(pair_name)
      swaps = Swaps.create(start_time, end_time)
      interval = resolve_collecting_interval(interval)
      Jiji::Model::Trading::Tick.where(
        :timestamp.gte => start_time,
        :timestamp.lt  => end_time
      ).map_reduce(
        MAP_TEMPLATE_FOR_FETCH.result(binding),
        REDUCE_TEMPLATE_FOR_FETCH.result(binding)
      ).out(inline: true).map do |r|
        convert_rate(r, swaps, pair, interval)
      end.sort_by(&:timestamp)
    end

    private

    MAP_TEMPLATE_FOR_FETCH = ERB.new %{
      function() {
        var partition = Math.floor(
          this.timestamp.getTime() / (<%= interval %>)) * (<%= interval %>);
        emit( partition,{
            bid: this.values[<%= pair.pair_id %>*2],
            ask: this.values[<%= pair.pair_id %>*2+1],
            timestamp:this.timestamp
        });
      }
    }

    REDUCE_TEMPLATE_FOR_FETCH = ERB.new %{
      function(key, values) {
        var result = values[0].open ? values[0] : {
          open:values[0], close:values[0],
          high:values[0],low:values[0],
          timestamp:key
        };
        for(var i=0;i<values.length;i++ ) {
          if (values[0].open && i==0) continue;
          var t = values[i];
          if (t.timestamp < result.open.timestamp)  result.open  = t ;
          if (t.timestamp > result.close.timestamp) result.close = t ;
          if (result.high.bid < t.bid) result.high  = t ;
          if (result.low.bid  > t.bid) result.low   = t ;
        }
        return result;
      }
    }

    def convert_rate(fetched_value, swaps, pair, interval)
      v = fetched_value['value']
      timestamp = resolve_timestamp(v, interval)
      Jiji::Model::Trading::Rate.new(
        pair,
        create_tick(pair, v['open']  || v, swaps),
        create_tick(pair, v['close'] || v, swaps),
        create_tick(pair, v['high']  || v, swaps),
        create_tick(pair, v['low']   || v, swaps),
        timestamp
      )
    end

    def create_tick(pair, hash, swaps)
      Jiji::Model::Trading::Tick.create_from_hash(pair, hash || v, swaps)
    end

    def calcurate_partition_start_time(time, interval)
      (time.to_i / (interval / 1000)).floor * (interval / 1000)
    end

    def resolve_timestamp(v, interval)
      if v['open']
        Time.at(v['timestamp'] / 1000)
      else
        Time.at(calcurate_partition_start_time(v['timestamp'], interval))
      end
    end

    def resolve_collecting_interval(interval)
      case interval
      when :one_minute      then       60 * 1000
      when :fifteen_minutes then    15 * 60 * 1000
      when :thirty_minutes  then    30 * 60 * 1000
      when :one_hour        then    60 * 60 * 1000
      when :six_hours       then  6 * 60 * 60 * 1000
      when :one_day         then 24 * 60 * 60 * 1000
      else fail ArgumentError, "unknown interval. interval=#{interval}"
      end
    end

  end
end
