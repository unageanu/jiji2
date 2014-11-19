# coding: utf-8

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all( "jiji/model" )

module Jiji
module Test  
  
  class DataBuilder
    
    def new_rate(seed)
      Jiji::Model::Trading::Rate.new {|r|
        r.pair_id     = seed
        r.open_price  = 100 + seed
        r.close_price = 101 + seed
        r.high_price  = 110 + seed
        r.low_price   = 90  + seed
        r.buy_swap    = 2   + seed
        r.sell_swap   = 20  + seed
        r.timestamp   = DateTime.new(seed+1000, 1, 1, 0, 0, 0)
      }
    end
    
    
    def clean
      Jiji::Model::Trading::Rate.delete_all
      Jiji::Model::Settings::SecuritySetting.delete_all
    end
    
  end
  
end
end
