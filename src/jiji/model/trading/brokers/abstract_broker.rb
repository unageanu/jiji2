# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji
module Model
module Trading

  class AbstractBroker
    
    attr_accessor :positions
    
    def initialize
      @positions = {}
    end
    
    def available_pairs
      @pairs_cache ||= retrieve_pairs
    end
    
    def current_rates
      @rates_cache ||= retrieve_rates
    end
    
    def refresh
      current_rates
      @pairs_cache = nil
      @rates_cache = nil
    end
    
  private
    def create_position( pair_name, count, sell_or_buy )
      pair = Pairs.instance.create_or_get(pair_name)
      tick = current_rates
      tick_value = tick[pair_name]
      Position.create( @back_test_id, pair.pair_id, count, sell_or_buy, 
        sell_or_buy == :sell ? tick_value.bid : tick_value.ask, tick.timestamp  )
    end
    
  end
  
end
end
end