# coding: utf-8

module Jiji::Model::Trading::Internal
class RMTNextTickJobGenerator
  
  include Jiji::Model::Trading::Jobs
  
  def initialize(wait_time=15)
    @wait_time = wait_time
    @running   = true
    @mutext    = Mutex.new
    @job       = NotifyNextTickJobForRMT.new
  end
  
  def start( queue )
    Thread.start(queue, @wait_time) {|q, wait|
      while ( active? )
        q.push(@job)
        sleep wait
      end
    }
  end
  
  def stop
     @mutext.synchronize {
        @running = false
     }
  end
  def active?
     @mutext.synchronize {
        @running
     }
  end
  
end
end
