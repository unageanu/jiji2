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
      @trading_unit_saver = Jiji::Model::Trading::Internal::TradingUnitSaver.new
    end
    
    def on_inject
      @broker = @rmt_broker
    end
    
    def do_next
      super
      wait
    end
    
  private
    def after_do_next
      store_rates
      store_trading_unit_hourly
    end
    
    def store_rates
      @rate_saver.save(@broker.tick)
    end
    def store_trading_unit_hourly
      now = time_source.now
      return if @next_save_point != nil && @next_save_point > now 
      
      @trading_unit_saver.save( @broker.pairs, now )
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
