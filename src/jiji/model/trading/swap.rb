# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'

module Jiji
module Model
module Trading

  class Swap
  
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    store_in collection: "swaps"
    
    field :pair_id,       type: Integer
    field :sell_swap,     type: Integer
    field :buy_swap,      type: Integer
    field :timestamp,      type: Time

    index({ :timestamp => 1 }, { name: "swaps_timestamp_index" })
    
    def self.delete( start_time, end_time )
      Swap.where({
        :timestamp.gte => start_time, 
        :timestamp.lt  => end_time 
      }).delete
    end
    
  protected
    def values
      [pair_id, sell_swap, buy_swap, timestamp]
    end
    
  end
  
  class Swaps
    
    def initialize( swaps, start_time, end_time )
      @swaps      = swaps
      @start_time = start_time
      @end_time   = end_time
    end
    
    def get_swap_at( pair_id, timestamp )
      check_period( timestamp )
      check_pair_id( pair_id )
      return @swaps[pair_id].bsearch {|s| s.timestamp <= timestamp }
    end
    
    def get_swaps_at( timestamp )
      check_period( timestamp )
      return @swaps.inject({}){|r,v|
        r[v[0]] = v[1].bsearch {|s| s.timestamp <= timestamp }
        r
      }
    end
    
    def self.create( start_time, end_time )
      Swaps.new( load(start_time, end_time), start_time, end_time )
    end
    
  private 
    def check_period(timestamp)
      unless timestamp >= @start_time && timestamp <= @end_time
        raise ArgumentError.new(
          "out of period. time=#{timestamp} start=#{@start_time} end=#{@start_time}")
      end
    end
    def check_pair_id(pair_id)
      unless @swaps.include?(pair_id)
        raise Jiji::Errors::NotFoundException.new(
          "pair is not found. pair_id=#{pair_id}")
      end
    end
    
    def self.load(start_time, end_time)
      start_time = caluculate_start_time(start_time)
      return Swap.where( 
        :timestamp.gte => start_time, 
        :timestamp.lte => end_time
      ).order_by(:timestamp.desc).inject({}){|r,v|
        r[v.pair_id] = [] unless r.include?( v.pair_id )
        r[v.pair_id] << v
        r
      }
    end
    
    def self.caluculate_start_time(start_time)
      # 開始時点のswapを必ず含めるため、
      # 開始より以前で最大のstart_timeを再計算する
      first = Swap.where( :timestamp.lte => start_time )
        .order_by(:timestamp.desc).only(:timestamp).first
      out_of_period(start_time) unless first
      return first.timestamp
    end
    
    def self.out_of_period(timestamp) 
       raise ArgumentError.new("out of period. time=#{timestamp}")
    end
    
  end

end
end
end
