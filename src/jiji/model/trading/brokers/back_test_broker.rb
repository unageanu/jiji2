# coding: utf-8

require 'securerandom'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/errors/errors'

module Jiji
module Model
module Trading
module Brokers

  class BackTestBroker < AbstractBroker
    
    include Jiji::Errors
    
    attr :start, :end
    
    def initialize(back_test_id, start_time, end_time)
      
      super()
      
      check_period(start_time, end_time)
      @start_time = start_time
      @end_time   = end_time
      @current    = start_time
      
      @back_test_id = back_test_id
      
      @buffer      = []
      @trade_units = Jiji::Model::Trading::Internal::TradeUnits.create(start_time, end_time)
    end
    
    def positions
      # TODO
    end
    
    def buy( pair_id, count )
      # TODO
    end
    
    def sell( pair_id )
      # TODO
    end
    
    def destroy
    end
    
    def has_next
      fill_buffer if @buffer.empty?
      !@buffer.empty?
    end
  
  private
    def retrieve_pairs
      instance = Jiji::Model::Trading::Pairs.instance
      rates = tick
      rates.map {|v|
        pair = instance.create_or_get(v[0])
        trade_unit = @trade_units.get_trade_unit_at(pair.pair_id, rates.timestamp)
        JIJI::Plugin::SecuritiesPlugin::Pair.new( pair.name, trade_unit.trade_unit )
      }
    end
    def retrieve_tick
      fill_buffer if @buffer.empty?
      @buffer.shift
    end

    def check_period( start_time, end_time )
      if start_time >= end_time
        illegal_argument("illegal period.", {
          :start_time=>start_time, 
          :end_time=>end_time
        }) 
      end
    end
  
    def fill_buffer
      while @buffer.empty? && @current < @end_time
        load_next_ticks
      end
    end
    
    def load_next_ticks
      start_time = @current
      end_time   = @end_time > @current+(60*60*2) ? @current+(60*60*2) : @end_time 
      @buffer += Tick.fetch( start_time, end_time )
      
      @current = end_time
    end
    
  end

end
end
end
end