# coding: utf-8

require 'encase'
require 'jiji/model/trading/jobs/abstract_job'

module Jiji
module Model
module Trading
module Internal

  class TradingUnitSaver
    
    def initialize
      @current = {}
    end
    
    def save( pairs, timestamp )
      pairs.each {|v|
        if ( changed?( v ) )
          save_trading_unit( v, timestamp)
          update_current( v )
        end
      }
    end
    
  private
    
    def changed?(value)
      current = @current[value.name]
      return current == nil \
          || current.trade_unit != value.trade_unit
    end
    
    def save_trading_unit(value, timestamp)
      pair = Pairs.instance.create_or_get(value.name)
      TradingUnit::new {|t|
        t.pair_id      = pair.pair_id
        t.trading_unit = value.trade_unit
        t.timestamp    = timestamp
      }.save
    end
    
    def update_current(value)
      @current[value.name] = value
    end
    
  end 

end
end
end
end
