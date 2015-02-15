# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
class Rate
  
  include Jiji::Utils::ValueObject
  include Jiji::Web::Transport::Transportable
  
  attr :pair, :open, :close, :high, :low, :timestamp
  
  def initialize( pair, open, close, high, low, timestamp )
    @pair      = pair
    @open      = open
    @close     = close
    @high      = high
    @low       = low
    @timestamp = timestamp
  end
  
  def buy_swap
    @open.buy_swap
  end
  def sell_swap
    @open.sell_swap
  end
  
  def self.create_from_tick( pair_name, *ticks )
    pair = Pairs.instance.create_or_get( pair_name )
    open = close = high = low = ticks[0]
    ticks.each {|t|
      open  = t if t.timestamp < open.timestamp
      close = t if t.timestamp > close.timestamp
      high  = t if high[pair_name].bid < t[pair_name].bid
      low   = t if low[pair_name].bid  > t[pair_name].bid
    }
    return Rate.new( pair,
      open[pair_name], close[pair_name], 
      high[pair_name], low[pair_name], open.timestamp)
  end
  
  def self.union( *rates )
    open = close = high = low = rates[0]
    rates.each {|r|
      open  = r if r.timestamp < open.timestamp
      close = r if r.timestamp > close.timestamp
      high  = r if high.high.bid < r.high.bid
      low   = r if low.low.bid  > r.low.bid
    }
    return Rate.new(open.pair, open.open, 
      close.close, high.high, low.low, open.timestamp)
  end
  
  def to_h
    {
      :pair      => pair,
      :open      => open,
      :close     => close,
      :high      => high,
      :low       => low,
      :timestamp => timestamp 
    }
  end
  
protected
  def values
    [pair, open, close, high, low, timestamp]
  end
  
end
end
