# coding: utf-8

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all( 'jiji/model' )

module Jiji::Test
  
  class DataBuilder
    
    include Jiji::Model::Trading
    
    def new_rate(seed, pair_name=:EURJPY)
      Rate.create_from_tick(
        pair_name, new_tick(seed), new_tick(seed+1), new_tick(seed+9), new_tick(seed-11)
      )
    end
    
    def new_tick(seed, timestamp=Time.at(0))
      values = [:EURJPY,:USDJPY,:EURUSD].inject({}) {|r, pair_name|
        r[pair_name] = new_tick_value(seed)
        r
      }
      Tick.create(values,timestamp)
    end
    
    def new_tick_value(seed)
      Tick::Value.new(
        100.00+seed, 100.003+seed, 2+seed, 20+seed)
    end
    
    def new_swap(seed, pair_id=1, timestamp=Time.at(0))
      Internal::Swap.new {|s|
        s.pair_id   = pair_id
        s.buy_swap  =  2 + seed
        s.sell_swap = 20 + seed
        s.timestamp = timestamp
      }
    end
    
    def new_trading_unit(seed, pair_id=1, timestamp=Time.at(0))
      Internal::TradingUnit.new {|s|
        s.pair_id    = pair_id
        s.trading_unit = 10000 * seed
        s.timestamp  = timestamp
      }
    end
    
    def new_position(seed, back_test_id=nil, pair_id=1, timestamp=Time.at(seed))
      Position.create( back_test_id,
        nil, pair_id, seed, 10000, seed % 2 == 0 ? :buy : :sell, new_tick(seed, timestamp))
    end
    
    def new_agent_body( seed, parent=nil ) 
       return <<BODY
class TestAgent#{seed} #{ parent ? " < " + parent : "" }
  
  include Jiji::Model::Agents::Agent
  
  def self.property_infos
    return [
      Property.new(:a, "aa", 1),
      Property.new(:b, "bb", #{seed})
    ]
  end
  
  def self.description
    "description#{seed}"
  end
  
end
BODY
    end
    
    def new_trading_context( broker=Mock::MockBroker.new, 
      time_source=Jiji::Utils::TimeSource.new, logger=Logger.new(STDOUT))
      TradingContext.new( nil, broker, time_source, logger )
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
      swap = Internal::Swap.new {|s|
        s.pair_id   = Pairs.instance.create_or_get(pair_id).pair_id
        s.buy_swap  = tick.buy_swap
        s.sell_swap = tick.sell_swap
        s.timestamp = timestamp
      }
      swap.save
    end
    
    def register_trading_unit( pair_id, timestamp )
      trading_unit = Internal::TradingUnit.new {|s|
        s.pair_id    = Pairs.instance.create_or_get(pair_id).pair_id
        s.trading_unit = 10000
        s.timestamp  = timestamp
      }
      trading_unit.save
    end
    
    def clean
      Tick.delete_all
      Pair.delete_all
      Internal::Swap.delete_all
      Internal::TradingUnit.delete_all
      BackTest.delete_all
      Position.delete_all
      Jiji::Model::Agents::AgentSource.delete_all
      Jiji::Model::Settings::AbstractSetting.delete_all
    end
    
  end
  
end
