# coding: utf-8

module Jiji::Model::Trading::Internal
  class RMTNextTickJobGenerator

    include Jiji::Model::Trading::Jobs

    def initialize(wait_time = 15)
      @wait_time = wait_time
      @running   = true
      @mutext    = Mutex.new
      @job       = NotifyNextTickJobForRMT.new
    end

    def start(queue)
      Thread.start(queue, @wait_time) do |q, wait|
        while  active?
          q.push(@job)
          sleep wait
        end
      end
    end

    def stop
      @mutext.synchronize do
        @running = false
      end
    end

    def active?
      @mutext.synchronize do
        @running
      end
    end

  end
end
