# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji
module Model
module Trading

  class AbstractBroker
    
    def initialize
      @positions = {}
    end
    
    def positions
      @positions
    end
    
    def pairs
      @pairs_cache ||= retrieve_pairs
    end
    
    def tick
      @rates_cache ||= retrieve_tick
    end
    
    def close( position_id )
      check_position_exists(position_id)
      
      position = @positions[position_id]
      do_close( position )
      position.close
    end
    
    def refresh
      tick
      @pairs_cache = nil
      @rates_cache = nil
    end
    
  private
    def create_position( pair_name, count, sell_or_buy, external_position_id )
      pair = Pairs.instance.create_or_get(pair_name)
      position = Position.create( @back_test_id, external_position_id, 
        pair.pair_id, count, resolve_trading_unit(pair_name), sell_or_buy, tick )
      @positions[position._id] = position
      position
    end
    
    def do_close( position )
    end
    
    def resolve_trading_unit(pair_name)
      pairs.find {|p| p.name.to_sym == pair_name.to_sym }.trade_unit
    end
    
  end
  
end
end
end