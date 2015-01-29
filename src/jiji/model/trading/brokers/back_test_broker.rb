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
    
    def initialize(back_test_id, start_time, end_time, tick_repository)
      
      super()
      
      check_period(start_time, end_time)
      @start_time = start_time
      @end_time   = end_time
      @current    = start_time
      
      @back_test_id = back_test_id
      
      
      tradingUnits = Jiji::Model::Trading::Internal::TradingUnits
      
      @buffer          = []
      @trading_units   = tradingUnits.create(start_time, end_time)
      @tick_repository = tick_repository
    end
    
    def buy( pair_name, count )
      create_position( pair_name, count, :buy, nil )
    end
    
    def sell( pair_name, count )
      create_position( pair_name, count, :sell, nil )
    end
    
    def destroy
    end
    
    def has_next
      fill_buffer if @buffer.empty?
      !@buffer.empty?
    end
    
    def refresh
      @buffer.shift
      super
    end
    
  private
    def retrieve_pairs
      instance = Jiji::Model::Trading::Pairs.instance
      rates = tick || []
      rates.map {|v|
        pair = instance.create_or_get(v[0])
        trading_unit = @trading_units.get_trading_unit_at(
            pair.pair_id, rates.timestamp)
        JIJI::Plugin::SecuritiesPlugin::Pair.new( 
            pair.name, trading_unit.trading_unit )
      }
    end
    def retrieve_tick
      fill_buffer if @buffer.empty?
      @buffer.first
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
      @buffer += @tick_repository.fetch( start_time, end_time )
      
      @current = end_time
    end
    
  end

end
end
end
end