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
    
    def initialize(wait_time=10)
      super()
      @wait_time = wait_time
      @rate_saver = Jiji::Model::Trading::Internal::RateSaver.new
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
      @rate_saver.save(@broker.current_rates)
    end
    
    def wait
      sleep @wait_time
    end
    
  end 

end
end
end
end
