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
        100.00+seed, 100.003+seed, 2+seed, 20+seed)
    end
    
    def new_swap(seed, pair_id=1, timestamp=Time.at(0))
      Jiji::Model::Trading::Internal::Swap.new {|s|
        s.pair_id   = pair_id
        s.buy_swap  =  2 + seed
        s.sell_swap = 20 + seed
        s.timestamp = timestamp
      }
    end
    
    def new_trading_unit(seed, pair_id=1, timestamp=Time.at(0))
      Jiji::Model::Trading::Internal::TradingUnit.new {|s|
        s.pair_id    = pair_id
        s.trading_unit = 10000 * seed
        s.timestamp  = timestamp
      }
    end
    
    def new_position(seed, back_test_id=nil, pair_id=1, timestamp=Time.at(seed))
      Jiji::Model::Trading::Position.create( back_test_id,
        nil, pair_id, seed, 10000, seed % 2 == 0 ? :buy : :sell, new_tick(seed, timestamp))
    end
    
    def register_ticks(count, interval=20)
      count.times {|i|
        t = new_tick(i%10, Time.at(interval*i))
        t.save
        
        t.each {|v|
          register_swap( v[0], v[1], t.timestamp )
          register_trading_unit( v[0], t.timestamp )
        }
      }
    end
    
    def register_back_test( seed, repository )
      repository.register({
        "name"       => "テスト#{seed}",
        "start_time" => Time.at(seed*100),
        "end_time"   => Time.at((seed+1)*200),
        "memo"       => "メモ#{seed}"
      })
    end
    
    def register_agent( seed )
      Jiji::Model::Agents::AgentSource.create(
        "test#{seed}", seed % 2 == 0 ? :agent : :lib, Time.at(100*seed), "", 
        "class Foo#{seed}; def to_s; return \"xxx#{seed}\"; end; end")
    end
    
    def register_swap( pair_id, tick, timestamp )
      swap = Jiji::Model::Trading::Internal::Swap.new {|s|
        s.pair_id   = Jiji::Model::Trading::Pairs.instance.create_or_get(pair_id).pair_id
        s.buy_swap  = tick.buy_swap
        s.sell_swap = tick.sell_swap
        s.timestamp = timestamp
      }
      swap.save
    end
    
    def register_trading_unit( pair_id, timestamp )
      trading_unit = Jiji::Model::Trading::Internal::TradingUnit.new {|s|
        s.pair_id    = Jiji::Model::Trading::Pairs.instance.create_or_get(pair_id).pair_id
        s.trading_unit = 10000
        s.timestamp  = timestamp
      }
      trading_unit.save
    end
    
    def clean
      Jiji::Model::Trading::Tick.delete_all
      Jiji::Model::Trading::Pair.delete_all
      Jiji::Model::Trading::Internal::Swap.delete_all
      Jiji::Model::Trading::Internal::TradingUnit.delete_all
      Jiji::Model::Trading::BackTest.delete_all
      Jiji::Model::Trading::Position.delete_all
      Jiji::Model::Agents::AgentSource.delete_all
      Jiji::Model::Settings::AbstractSetting.delete_all
    end
    
  end
  
end
end
