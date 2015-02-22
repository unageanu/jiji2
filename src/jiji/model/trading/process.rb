# coding: utf-8

require 'thread'

module Jiji::Model::Trading
  class Process
    attr_reader :job_queue

    def initialize(trading_context, pool, fail_on_error = false)
      @trading_context = trading_context
      @pool            = pool
      @fail_on_error   = fail_on_error
      @job_queue       = Queue.new
    end

    def start
      @task = @pool.process(@trading_context, @job_queue) do|context, queue|
        begin
          context.prepare_running
          while  context.alive? || !queue.empty?
            do_next_job(context, queue)
          end
          context.post_running
        rescue Exception => e
          context.fail(e)
        end
      end
    end

    def do_next_job(context, queue)
      queue.pop.exec(context, queue)
    rescue Exception => e
      @trading_context.logger.error(e)
      raise e if @fail_on_error
    end

    def stop
      post_exec { |c| c.request_cancel }.value
      sleep 0.1 until finished?
    end

    def post_exec(&block)
      job = Jiji::Model::Trading::Jobs::Job.create_from(&block)
      post_job(job).future
    end

    def post_job(job)
      unless running?
        job.exec(@trading_context, @job_queue)
      else
        @job_queue.push(job)
      end
      job
    end

    def alive_context?
      post_exec { |c| c.alive? }.value
    end

    def running?
      !@task.nil? && @task.running?
    end

    def finished?
      !@task.nil? && @task.finished?
    end
  end
end
