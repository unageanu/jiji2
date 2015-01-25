# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'

module Jiji
module Model
module Trading
module Internal

  class TradingUnit
  
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    store_in collection: "trading_units"
    
    field :pair_id,       type: Integer
    field :trading_unit,    type: Integer
    field :timestamp,     type: Time

    index({ :timestamp => 1 }, { name: "trading_units_timestamp_index" })
    
    attr_readonly :pair_id, :trading_unit, :timestamp

    
    def self.delete( start_time, end_time )
      TradingUnit.where({
        :timestamp.gte => start_time, 
        :timestamp.lt  => end_time 
      }).delete
    end
    
  private
    def values
      [pair_id, trace_unit, timestamp]
    end
    
  end
  
  class TradingUnits

    def initialize( values )
      @values = values
    end
    
    def get_trading_unit_at( pair_id, timestamp )
      check_pair_id( pair_id )
      return @values[pair_id].get_at(timestamp)
    end
    
    def get_trading_units_at( timestamp )
      return @values.inject({}){|r,v|
        r[v[0]] = v[1].get_at(timestamp)
        r
      }
    end
    
    def self.create( start_time, end_time )
      data = Jiji::Utils::HistoricalData.load( TradingUnit, start_time, end_time).inject({}){|r,v|
        r[v.pair_id] = [] unless r.include?( v.pair_id )
        r[v.pair_id] << v
        r
      }.inject({}){|r,v|
        r[v[0]] = Jiji::Utils::HistoricalData.new( v[1], start_time, end_time )
        r
      }
      TradingUnits.new( data )
    end
    
  private 
    def check_pair_id(pair_id)
      unless @values.include?(pair_id)
        raise Jiji::Errors::NotFoundException.new(
          "pair is not found. pair_id=#{pair_id}")
      end
    end
    
  end

end
end
end
end
