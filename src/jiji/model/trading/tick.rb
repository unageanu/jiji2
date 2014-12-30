# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Trading

  class Tick
    
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    store_in collection: "ticks"
    
    field :pair_id,  type: Symbol
    
    field :bid,       type: Float
    field :ask,       type: Float
    field :sell_swap, type: Integer
    field :buy_swap,  type: Integer
    
    field :timestamp, type: Time
    
    index({ :timestamp=> 1 }, { name: "ticks_timstamp_index" })
    index({ :pair_id => 1, :timestamp=> 1 }, { name: "ticks_pair_id_timstamp_index" })
    
    def self.fetch_all( start_time, end_time )
      return Tick.where({
        :timestamp.gte => start_time, 
        :timestamp.lt => end_time 
      }).map_reduce(
        MAP_TEMPLATE_FOR_FETCH_ALL_TICKS.result(binding), 
        REDUCE_TEMPLATE_FOR_FETCH_ALL_TICKS.result(binding)
      ).out(inline: true).map {|values|
        values.reduce({}) {|r,v|
          pair_id    = v[0].to_sym
          r[pair_id] = Tick.create_from_hash( pair_id, v[1] )
          r
        }
      }
    end
    
    def self.create_from_hash(pair_id, hash)
      Tick.new {|t|
        t.pair_id   = pair_id
        t.bid       = hash["bid"]
        t.ask       = hash["ask"]
        t.buy_swap  = hash["buy_swap"]
        t.sell_swap = hash["sell_swap"]
        t.timestamp = hash["timestamp"]
      }
    end
    
    def values
      [pair_id, bid, ask, sell_swap, buy_swap, timestamp]
    end

  private
    MAP_TEMPLATE_FOR_FETCH_ALL_TICKS = ERB.new %Q{
      function() {
        emit( this.timestamp, this );
      }
    }

    REDUCE_TEMPLATE_FOR_FETCH_ALL_TICKS = ERB.new %Q{
      function(key, values) {
        var result = {};
        values.forEach(function(v) {
          result[v.pair_id] = v
        });
        return result;
      }
    }

  end

end
end
end