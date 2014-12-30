# coding: utf-8

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all( "jiji/model" )

module Jiji
module Test  
  
  class DataBuilder
    
    def new_rate(seed)
      Jiji::Model::Trading::Rate.create_from_tick(
        new_tick(seed), new_tick(seed+1), new_tick(seed+9), new_tick(seed-11), 
      )
    end
    
    def new_tick(seed, time = Time.utc(seed+1000, 1, 1, 0, 0, 0))
      Jiji::Model::Trading::Tick.new {|r|
        r.pair_id     = seed%2 == 0 ? :USDJPY : :EURJPY
        r.bid         = 100 + seed
        r.ask         = 99 + seed
        r.buy_swap    = 2   + seed
        r.sell_swap   = 20  + seed
        r.timestamp   = time
      }
    end
    
    def clean
      Jiji::Model::Trading::Tick.delete_all
      Jiji::Model::Settings::AbstractSetting.delete_all
    end
    
  end
  
end
end
