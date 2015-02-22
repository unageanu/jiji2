# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Model::Trading::Brokers
class AbstractBroker

  include Jiji::Model::Trading

  def initialize
    @positions = {}
  end
  
  def positions
    @positions
  end
  
  def pairs
    @pairs_cache ||= retrieve_pairs
  end
  
  def tick
    @rates_cache ||= retrieve_tick
  end
  
  def close( position_id )
    check_position_exists(position_id)
    
    position = @positions[position_id]
    do_close( position )
    position.close
    
    @positions.delete position_id
  end
  
  def refresh
    @pairs_cache = nil
    @rates_cache = nil
    update_positions if has_next?
  end
  
private
  def update_positions
    @positions.values.each {|p| 
      p.update( tick ) 
    }
  end

  def create_position( pair_name, count, sell_or_buy, external_position_id )
    illegal_state( "tick is not exists." ) unless tick  
    pair = Pairs.instance.create_or_get(pair_name)
    position = Position.create( @back_test_id, external_position_id, 
      pair.pair_id, count, resolve_trading_unit(pair_name), sell_or_buy, tick )
    @positions[position._id] = position
    position
  end
  
  def do_close( position )
  end
  
  def resolve_trading_unit(pair_name)
    pairs.find {|p| p.name.to_sym == pair_name.to_sym }.trade_unit
  end
  
  def check_position_exists(position_id)
    unless @positions.include? position_id
      not_found( Jiji::Model::Trading::Position, id=>position_id ) 
    end
  end
  
end
end