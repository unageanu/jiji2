# coding: utf-8

require 'encase'
require 'jiji/model/trading/jobs/abstract_job'

module Jiji
module Model
module Trading
module Jobs

  class RMTJob < AbstractJob
    
    include Encase
    
    needs :rmt_broker
    needs :logger
    needs :time_source
    
    def initialize(wait_time=10)
      super()
      @wait_time = wait_time
      @rate_saver = Jiji::Model::Trading::Internal::RateSaver.new
      @trade_unit_saver = Jiji::Model::Trading::Internal::TradeUnitSaver.new
    end
    
    def on_inject
      @broker = @rmt_broker
    end
    
    def do_next
      super
      wait
    end
    
  protected
    def after_do_next
      store_rates
      store_trade_unit_hourly
    end
    
  private
    def store_rates
      @rate_saver.save(@broker.current_rates)
    end
    def store_trade_unit_hourly
      now = time_source.now
      return if @next_save_point != nil && @next_save_point > now 
      
      @trade_unit_saver.save( @broker.available_pairs, now )
      @next_save_point = now + 60*60
    end
    
    def wait
      sleep @wait_time
    end
    
  end 

end
end
end
end
