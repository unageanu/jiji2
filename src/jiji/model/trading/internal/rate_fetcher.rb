# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Trading
module Internal

  class RateFetcher
    
    def fetch( pair_name, start_time, end_time, interval=:one_minute )
      pair = Pairs.instance.create_or_get( pair_name )
      swaps = Swaps.create( start_time, end_time )
      interval = resolve_collecting_interval(interval)
      return Tick.where({
        :timestamp.gte => start_time, 
        :timestamp.lt  => end_time 
      }).map_reduce(
        MAP_TEMPLATE_FOR_FETCH.result(binding), 
        REDUCE_TEMPLATE_FOR_FETCH.result(binding)
      ).out(inline: true).map {|r|
        convert_rate(r, swaps, pair, interval)
      }.sort_by{|v| v.timestamp}
    end
    
  private
    
    MAP_TEMPLATE_FOR_FETCH = ERB.new %Q{
      function() {
        emit( Math.floor(this.timestamp.getTime() / (<%= interval.to_s %>)) * (<%= interval.to_s %>), 
          { bid: this.values[<%= pair.pair_id %>*2], ask: this.values[<%= pair.pair_id %>*2+1], timestamp:this.timestamp});
      }
    }

    REDUCE_TEMPLATE_FOR_FETCH = ERB.new %Q{
      function(key, values) {
        var result = values[0].open ? values[0] : {open:values[0],close:values[0],high:values[0],low:values[0], timestamp:key};
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
      v = fetched_value["value"]
      timestamp = nil
      if v["open"] 
        timestamp = Time.at(v["timestamp"] / 1000)
      else
        timestamp = Time.at(calcurate_partition_start_time(v["timestamp"], interval))
      end
      Rate.new(
        pair,
        Tick.create_from_hash( pair, v["open"]  || v, swaps),
        Tick.create_from_hash( pair, v["close"] || v, swaps),
        Tick.create_from_hash( pair, v["high"]  || v, swaps),
        Tick.create_from_hash( pair, v["low"]   || v, swaps),
        timestamp
      )
    end
    
    def calcurate_partition_start_time(time, interval)
      (time.to_i/(interval/1000)).floor * (interval/1000)
    end
  
    def resolve_collecting_interval(interval)
      case interval
      when :one_minute      then       60*1000
      when :fifteen_minutes then    15*60*1000
      when :thirty_minutes  then    30*60*1000
      when :one_hour        then    60*60*1000
      when :six_hours       then  6*60*60*1000
      when :one_day         then 24*60*60*1000
      else raise ArgumentError.new("unknown interval. interval=#{interval}") 
      end
    end
    
  end
  
end
end
end
end
