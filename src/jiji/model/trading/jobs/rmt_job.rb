# coding: utf-8

require 'encase'
require 'jiji/model/trading/jobs/abstract_job'

module Jiji
module Model
module Trading
module Jobs

  class RMTJob < AbstractJob
    
    needs :rmt_broker
    
    def initialize(wait_time=10)
      super()
      @wait_time = wait_time
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
    end
    
  private
    def store_rates
      @broker.current_rates.each {|k,v|
        v.save
      }
    end
    
    def wait
      sleep @wait_time
    end
    
  end 

end
end
end
end
