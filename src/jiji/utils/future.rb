require 'thread'

module Jiji::Utils
class Future

  def initialize
    @queue = Queue.new
  end
  
  def value
    v = @queue.pop
    if v.is_a? Exception
      raise v
    else
      return v
    end
  end
  
  def value=(val)
    @queue << val
  end
  def error=(val)
    @queue << val
  end
end
end