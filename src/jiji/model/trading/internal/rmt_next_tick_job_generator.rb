# coding: utf-8

module Jiji::Model::Trading::Internal
  class RMTNextTickJobGenerator

    include Jiji::Model::Trading::Jobs

    def initialize(wait_time = (ENV['TICK_INTERVAL'] || 15).to_i)
      @wait_time = wait_time
      @running   = true
      @mutex    = Mutex.new
      @job       = NotifyNextTickJobForRMT.new
    end

    def start(queue)
      Thread.start(queue, @wait_time) do |q, wait|
        while active?
          q.push(@job)
          sleep wait
        end
      end
    end

    def stop
      locked = @mutex.try_lock
      @running = false
      @mutex.unlock if locked
    end

    def active?
      @mutex.synchronize do
        @running
      end
    end

  end
end
