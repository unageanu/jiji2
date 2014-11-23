# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Trading

  class Rate
    
    include Jiji::Utils::ValueObject
    
    attr :open, :close, :high, :low
    
    def initialize( open, close, high, low )
      @open  = open
      @close = close
      @high  = high
      @low   = low
    end
    
    def pair_id
      @open.pair_id
    end
    def timestamp
      @open.timestamp
    end
    def buy_swap
      @open.buy_swap
    end
    def sell_swap
      @open.sell_swap
    end
    
    def self.create_from_tick( *ticks )
      open = close = high = low = ticks[0]
      ticks.each {|t|
        open  = t if t.timestamp < open.timestamp
        close = t if t.timestamp > close.timestamp
        high  = t if high.bid < t.bid
        low   = t if low.bid  > t.bid
      }
      return Rate.new(open, close, high, low)
    end
    
    def self.union( *rates )
      open  = rates[0].open
      close = rates[0].close 
      high  = rates[0].high 
      low   = rates[0].low
      rates.each {|r|
        open  = r.open  if r.open.timestamp < open.timestamp
        close = r.close if r.close.timestamp > close.timestamp
        high  = r.high  if high.bid < r.high.bid
        low   = r.low   if low.bid  > r.low.bid
      }
      return Rate.new(open, close, high, low)
    end
  
  protected
    def values
      [pair_id, open, close, high, low]
    end
    
  end
  
end
end
end
