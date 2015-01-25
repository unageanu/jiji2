# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/utils/historical_data'
require 'thread'
require 'singleton'

module Jiji
module Model
module Trading
module Internal
  
  class Swap
  
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    store_in collection: "swaps"
    
    field :pair_id,       type: Integer
    field :sell_swap,     type: Integer
    field :buy_swap,      type: Integer
    field :timestamp,      type: Time

    index({ :timestamp => 1 }, { name: "swaps_timestamp_index" })
    
    attr_readonly :pair_id, :sell_swap, :buy_swap, :timestamp
    
    def self.delete( start_time, end_time )
      Swap.where({
        :timestamp.gte => start_time, 
        :timestamp.lt  => end_time 
      }).delete
    end
    
  private
    def values
      [pair_id, sell_swap, buy_swap, timestamp]
    end
    
  end
  
  class Swaps
    
    def initialize( swaps )
      @swaps      = swaps
    end
    
    def get_swap_at( pair_id, timestamp )
      check_pair_id( pair_id )
      return @swaps[pair_id].get_at(timestamp)
    end
    
    def get_swaps_at( timestamp )
      return @swaps.inject({}){|r,v|
        r[v[0]] = v[1].get_at(timestamp)
        r
      }
    end
    
    def self.create( start_time, end_time )
      data = Jiji::Utils::HistoricalData.load( Swap, start_time, end_time).inject({}){|r,v|
        r[v.pair_id] = [] unless r.include?( v.pair_id )
        r[v.pair_id] << v
        r
      }.inject({}){|r,v|
        r[v[0]] = Jiji::Utils::HistoricalData.new( v[1], start_time, end_time )
        r
      }
      Swaps.new( data )
    end
    
  private 
    def check_pair_id(pair_id)
      unless @swaps.include?(pair_id)
        raise Jiji::Errors::NotFoundException.new(
          "pair is not found. pair_id=#{pair_id}")
      end
    end
    
  end

end
end
end
end
