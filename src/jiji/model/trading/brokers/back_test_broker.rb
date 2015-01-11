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
    
    def initialize(start_time, end_time)
      check_period(start_time, end_time)
      @start_time = start_time
      @end_time   = end_time
      @current    = start_time
      
      @buffer     = []
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
    
  protected
    def retrieve_pairs
      instance = Jiji::Model::Trading::Pairs.instance
      current_rates.map {|v|
        instance.create_or_get(v[0])
      }
    end
    def retrieve_rates
      fill_buffer if @buffer.empty?
      @buffer.shift
    end
  
  private
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