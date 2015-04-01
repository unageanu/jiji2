# coding: utf-8

require 'jiji/utils/abstract_historical_data_fetcher'

module Jiji::Model::Trading::Internal
  class RateFetcher < Jiji::Utils::AbstractHistoricalDataFetcher

    include Jiji::Errors

    def fetch(pair_name, start_time, end_time, interval = :one_minute)
      pair = Jiji::Model::Trading::Pairs.instance.get_by_name(pair_name)
      swaps = Swaps.create(start_time, end_time)
      interval = resolve_collecting_interval(interval)
      q = fetch_ticks_within(start_time, end_time)
      q = aggregate_by_interval(q, binding)
      q = convert_results(q, interval, pair, swaps)
      q.sort_by(&:timestamp)
    end

    private

    def fetch_ticks_within(start_time, end_time)
      Jiji::Model::Trading::Tick.where(
        :timestamp.gte => start_time,
        :timestamp.lt  => end_time
      )
    end

    def convert_results(q, interval, pair, swaps)
      q.map do |fetched_value|
        convert_rate(fetched_value, swaps, pair, interval)
      end
    end

    def map_function(context)
      pair = context.local_variable_get('pair')
      context.local_variable_set('required_values', %(
        bid: this.values["#{pair.pair_id}"][0],
        ask: this.values["#{pair.pair_id}"][1]
            ))
      MAP_TEMPLATE.result(context)
    end

    def reduce_function(context)
      context.local_variable_set('check', 'values[0].open')
      context.local_variable_set('default_value', %({
        open:values[0], close:values[0],
        high:values[0], low:values[0],
        timestamp:key
      }))
      context.local_variable_set('reducer', REDUCER)
      REDUCE_TEMPLATE.result(context)
    end

    def convert_rate(fetched_value, swaps, pair, interval)
      v = fetched_value['value']
      timestamp = resolve_timestamp(v, interval)
      Jiji::Model::Trading::Rate.new(
        pair, timestamp,
        create_tick(pair, v['open']  || v, swaps),
        create_tick(pair, v['close'] || v, swaps),
        create_tick(pair, v['high']  || v, swaps),
        create_tick(pair, v['low']   || v, swaps)
      )
    end

    def create_tick(pair, hash, swaps)
      Jiji::Model::Trading::Tick.create_from_hash(pair, hash || v, swaps)
    end

    REDUCER = %{
      var t = item;
      if (t.timestamp < result.open.timestamp)  result.open  = t ;
      if (t.timestamp > result.close.timestamp) result.close = t ;
      if (result.high.bid < t.bid) result.high  = t ;
      if (result.low.bid  > t.bid) result.low   = t ;
    }

  end
end
