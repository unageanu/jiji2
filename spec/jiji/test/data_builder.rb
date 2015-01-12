# coding: utf-8

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all( "jiji/model" )

module Jiji
module Test  
  
  class DataBuilder
    
    def new_rate(seed, pair_name=:EURJPY)
      Jiji::Model::Trading::Rate.create_from_tick(
        pair_name, new_tick(seed), new_tick(seed+1), new_tick(seed+9), new_tick(seed-11)
      )
    end
    
    def new_tick(seed, timestamp=Time.at(0))
      values = [:EURJPY,:USDJPY,:EURUSD].inject({}) {|r, pair_name|
        r[pair_name] = new_tick_value(seed)
        r
      }
      Jiji::Model::Trading::Tick.create(values,timestamp)
    end
    
    def new_tick_value(seed)
      Jiji::Model::Trading::Tick::Value.new(
        100.0+seed, 99.0+seed, 2+seed, 20+seed)
    end
    
    def new_swap(seed, pair_id=1, timestamp=Time.at(0))
      Jiji::Model::Trading::Swap.new {|s|
        s.pair_id   = pair_id
        s.buy_swap  =  2 + seed
        s.sell_swap = 20 + seed
        s.timestamp = timestamp
      }
    end
    
    def register_ticks(count, interval=20)
      count.times {|i|
        t = new_tick(i%10, Time.at(interval*i))
        t.save
        
        t.each {|v|
          swap = Jiji::Model::Trading::Swap.new {|s|
            s.pair_id   = Jiji::Model::Trading::Pairs.instance.create_or_get(v[0]).pair_id
            s.buy_swap  = v[1].buy_swap
            s.sell_swap = v[1].sell_swap
            s.timestamp = t.timestamp
          }
          swap.save
        }
      }
    end
    
    def clean
      Jiji::Model::Trading::Tick.delete_all
      Jiji::Model::Trading::Pair.delete_all
      Jiji::Model::Trading::Swap.delete_all
      Jiji::Model::Trading::BackTest.delete_all
      Jiji::Model::Settings::AbstractSetting.delete_all
    end
    
  end
  
end
end
