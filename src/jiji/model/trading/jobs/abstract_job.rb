# coding: utf-8

require 'encase'
require 'thread'

module Jiji
module Model
module Trading
module Jobs

  class AbstractJob
    
    attr :broker
    attr :agents
    attr :status
    
    def initialize
      @agents = Jiji::Model::Agents::Agents.new
      @status = :wait_for_start
    end
    
    def prepare_running 
      @status = :running
    end
    
    def post_running
      @status = @status == :wait_for_cancel ? :canceled : :finished
    end
      
    def do_next
      begin 
        before_do_next
        @agents.next_tick( @broker )
        after_do_next
      rescue => e 
        @logger.error(e) if @logger
      end
    end
    
    def request_cancel
      @status = :wait_for_cancel
    end
  
    def has_next
      @status == :running && @broker.has_next
    end
  
  private
    def before_do_next
      @broker.refresh
    end
    def after_do_next
    end
  
  end 

end
end
end
end
