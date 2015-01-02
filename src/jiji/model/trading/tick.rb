# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Trading
  
  
  class Tick
    
    include Enumerable
    include Mongoid::Document
    
    store_in collection: "ticks"
    
    field :values,    type: Array
    field :timestamp, type: Time
    
    attr_accessor :swaps
    
    index({ :timestamp=> 1 }, { name: "ticks_timestamp_index" })
    
    def self.create(pair_and_values, timestamp)
      Tick.new {|t|
        t.values    = conert_to_array(pair_and_values)
        t.timestamp = timestamp
        t.swaps     = create_swaps(pair_and_values, timestamp)
      }
    end
    
    def [](pair_name)
      pair = Pairs.instance.create_or_get(pair_name)
      return create_value( pair )
    end
    
    def each(&block)
      0.upto(values.length/2) {|i|
        pair = Pairs.instance.get_by_id(i)
        if (pair != nil) 
          block.call([pair.name, self[pair.name]])
        end
      }
    end
    
    def self.fetch( start_time, end_time )
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
    
    def self.create_from_hash(pair, hash, swaps)
      swap = swaps.get_swap_at(pair.pair_id, hash["timestamp"])
      Tick::Value.new(hash["bid"],hash["ask"], swap.buy_swap, swap.sell_swap )
    end
    
    class Value
      include Jiji::Utils::ValueObject
      
      attr :bid, :ask, :buy_swap, :sell_swap
      
      def initialize(bid=0, ask=0, buy_swap=0, sell_swap=0) 
        @bid = bid
        @ask = ask
        @sell_swap = sell_swap
        @buy_swap = buy_swap
      end
      
      def values
        [bid, ask, buy_swap, sell_swap]
      end
      
    end

  private
    def self.conert_to_array(pair_and_values)
      pair_and_values.inject([]) {|r,v|
        pair = Pairs.instance.create_or_get(v[0])
        r[pair.pair_id*2]   = v[1].bid
        r[pair.pair_id*2+1] = v[1].ask
        r
      }
    end
    
    def create_value(pair)
      if pair == nil || pair.pair_id < 0 || pair.pair_id*2+1 > values.size
        raise ArgumentError.new( "illegal pair. pair=#{pair}" )
      end
      bid  = values[pair.pair_id*2]
      ask  = values[pair.pair_id*2+1]
      swap = @swaps[pair.pair_id]
      Value.new( bid, ask, swap.buy_swap, swap.sell_swap )
    end
    
    def self.create_swaps(pair_and_values, timestamp)
      pair_and_values.inject({}) {|r,v|
        pair = Pairs.instance.create_or_get(v[0])
        r[pair.pair_id] = Swap.new {|s|
          s.pair_id   = pair.pair_id
          s.buy_swap  = v[1].buy_swap  
          s.sell_swap = v[1].sell_swap
          s.timestamp = timestamp
        }
        r
      }
    end
    
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
  
  class NilTick
    include Enumerable
   
    attr :timestamp
    
    def initialize(timestamp=Time.now)
      @timestamp = timestamp
    end
    
    def [](pair_name)
      return nil
    end
    
    def each(&block)
    end
    
    def save
    end
    
  end
  
end
end
end