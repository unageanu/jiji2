# coding: utf-8

require 'thread'
require 'securerandom'

module Jiji::Model::Trading::Processes
class AbstractProcess
  
  attr :id, :job
  
  def initialize(job, pool, logger)
    @id = new_id 
    @job = job
    @pool = pool
    @logger = logger
    @message_queue = Queue.new
  end
  
  def start
    @task = @pool.process(@job) {|job|
      
      #job.prepare_running
      #while ( job.has_next )
      #  @message_queue.pop.exec(job)
      #end
      #job.post_running
      
      begin
        job.prepare_running
        while ( job.has_next )
          job.do_next
          process_message
        end
        job.post_running
      ensure
        process_message
      end
    }
  end
  
  def stop
    post_message {|job|
      job.request_cancel
    }
  end

  def post_message(&block)
    message = Message.new(block)
    unless running?
      message.exec(@job)
    else
      @message_queue << message
    end
    message.future
  end
  
  def running?
    @task != nil && @task.running?
  end
  def finished?
    @task != nil && @task.finished?
  end
      
private
  def process_message
    while !@message_queue.empty?
      @message_queue.pop.exec(@job)
    end
  end
  def new_id
    SecureRandom.uuid
  end
end 

class Message
  
  attr :future, :task
  
  def initialize(task)
    @task = task
    @future = Future.new
  end
  def exec(job)
    begin 
      @future.value = task.call(job)
    rescue => e 
      @future.error = e
    end
  end
end

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
