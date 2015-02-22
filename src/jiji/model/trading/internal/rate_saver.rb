# coding: utf-8

require 'encase'

module Jiji::Model::Trading::Internal
class RateSaver
  
  def initialize
    @current_swap = {}
  end
  
  def save( rates )
    rates.save
    save_swap_if_required(rates)
  end
  
private
  
  def save_swap_if_required(rates)
    rates.each {|v|
      if ( swap_changed?( v[0], v[1] ) )
        save_swap( v[0], v[1], rates.timestamp)
        update_current_swap( v[0], v[1] )
      end
    }
  end
  
  def swap_changed?(pair_name, value)
    current = @current_swap[pair_name]
    return current == nil \
      || current.buy_swap  != value.buy_swap \
      || current.sell_swap != value.sell_swap
  end
  
  def save_swap(pair_name, value, timestamp)
    pair = Jiji::Model::Trading::Pairs.instance.create_or_get(pair_name)
    Swap::new {|s|
      s.pair_id = pair.pair_id
      s.buy_swap = value.buy_swap
      s.sell_swap = value.sell_swap
      s.timestamp = timestamp
    }.save
  end
  
  def update_current_swap(pair_name, value)
    @current_swap[pair_name] = value
  end
  
end
end
