require 'date'

module Jiji
module Utils
  
  class TimeSource
    
    KEY = :jiji_time_source__now
    
    def now
      Thread.current[KEY] || Time.now
    end
    
    def set( time )
      Thread.current[KEY] = time || Time.now
    end
    
    def reset
      Thread.current[KEY] = nil
    end
    
  end
  
end
end