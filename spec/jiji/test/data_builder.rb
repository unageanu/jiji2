# coding: utf-8

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all( "jiji/model" )

module Jiji
module Test  
  
  class DataBuilder
    
    def new_rate(seed)
      Jiji::Model::Dao::Rate.new {|r|
        r.pair      = seed
        r.open      = 100 + seed
        r.close     = 101 + seed
        r.high      = 110 + seed
        r.low       = 90  + seed
        r.buy_swap  = 2   + seed
        r.sell_swap = 20  + seed
        r.timestamp = DateTime.new(seed+1000, 1, 1, 0, 0, 0)
      }
    end
    
    def new_setting(category, values)
      Jiji::Model::Dao::Setting.new {|r|
        r.category = seed
        r.values   = values
      }
    end
    
    def clean
      Jiji::Model::Dao::Rate.delete_all
      Jiji::Model::Dao::Setting.delete_all
    end
    
  end
  
end
end
