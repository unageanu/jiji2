# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Trading

  class Rate
    
    include Jiji::Utils::ValueObject
    
    attr :open, :close, :high, :low, :timestamp
    
    def initialize( open, close, high, low, timestamp )
      @open      = open
      @close     = close
      @high      = high
      @low       = low
      @timestamp = timestamp
    end
    
    def pair_id
      @open.pair_id
    end
    def buy_swap
      @open.buy_swap
    end
    def sell_swap
      @open.sell_swap
    end
    
    def self.create_from_tick( *ticks )
      open = close = high = low = ticks[0]
      ticks.each {|t|
        open  = t if t.timestamp < open.timestamp
        close = t if t.timestamp > close.timestamp
        high  = t if high.bid < t.bid
        low   = t if low.bid  > t.bid
      }
      return Rate.new(open, close, high, low, open.timestamp)
    end
    
    def self.union( *rates )
      open  = rates[0].open
      close = rates[0].close 
      high  = rates[0].high 
      low   = rates[0].low
      rates.each {|r|
        open  = r.open  if r.open.timestamp < open.timestamp
        close = r.close if r.close.timestamp > close.timestamp
        high  = r.high  if high.bid < r.high.bid
        low   = r.low   if low.bid  > r.low.bid
      }
      return Rate.new(open, close, high, low, open.timestamp)
    end
    
    def self.fetch( pair_id, start_time, end_time, interval=:one_minute )
      interval = resolve_collecting_interval(interval)
      return Tick.where({
        :pair_id => pair_id, 
        :timestamp.gte => start_time, 
        :timestamp.lt  => end_time 
      }).map_reduce(
        MAP_TEMPLATE_FOR_FETCH.result(binding), 
        REDUCE_TEMPLATE_FOR_FETCH.result(binding)
      ).out(inline: true).map {|r|
        v = r["value"]
        timestamp = nil
        if v["open"] 
          timestamp = Time.at(v["timestamp"] / 1000)
        else
          timestamp = Time.at(calcurate_partition_start_time(v["timestamp"], interval))
        end
        Rate.new(
          Tick.create_from_hash( pair_id, v["open"]  || v),
          Tick.create_from_hash( pair_id, v["close"] || v),
          Tick.create_from_hash( pair_id, v["high"]  || v),
          Tick.create_from_hash( pair_id, v["low"]   || v),
          timestamp
        )
      }.sort_by{|v| v.timestamp}
    end
    
    
    def self.delete( pair_id, start_time, end_time, pairs=nil )
      
    end
    
    def self.range( pair_id )
      
    end
    
    MAP_TEMPLATE_FOR_FETCH = ERB.new %Q{
      function() {
        emit( Math.floor(this.timestamp.getTime() / (<%= interval.to_s %>)) * (<%= interval.to_s %>), this);
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
    
  protected
    def values
      [pair_id, open, close, high, low]
    end
  
  private 
    def self.calcurate_partition_start_time(time, interval)
      (time.to_i/(interval/1000)).floor * (interval/1000)
    end
  
    def self.resolve_collecting_interval(interval)
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
