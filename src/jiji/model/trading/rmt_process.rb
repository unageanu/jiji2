# coding: utf-8

require 'encase'
require 'thread'

module Jiji
module Model
module Trading

  class RMTProcess
    
    include Encase
    
    needs :rmt_job
    needs :logger
    
    def initialize
      @message_queue = Queue.new
    end
    
    def start
      @thread = Thread.start(@rmt_job) {|job|
        job.prepare_running
        while ( job.has_next )
          job.do_next
          process_message
        end
        job.post_running
      }
    end
    
    def stop
      post_message {|job|
        job.request_cancel
      }
    end

    def post_message(&block)
      @message_queue << block
    end
    
  private
    def process_message
      while !@message_queue.empty?
        begin 
          @message_queue.pop.call(@job)
        rescue => e 
          @logger.error(e)
        end
      end
    end
    
  end 

end
end
end
