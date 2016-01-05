# coding: utf-8

require 'thread'

module Jiji::Model::Trading
  class Process

    attr_reader :job_queue

    def initialize(trading_context, pool, fail_on_error = false, priority = 0)
      @trading_context = trading_context
      @pool            = pool
      @fail_on_error   = fail_on_error
      @priority        = priority
      @job_queue       = Queue.new
    end

    def start(initial_job = [])
      initial_job.each { |j| @job_queue << j }
      @trading_context.prepare_start
      @task = @pool.process(@trading_context,
        @job_queue, @priority) do |context, queue, priority|
        Thread.current.priority = priority
        run(context, queue)
      end
    end

    def run(context, queue)
      context.prepare_running
      do_next_job(context, queue) while context.alive? || !queue.empty?
      context.post_running
    rescue Exception => e # rubocop:disable Lint/RescueException
      context.fail(e)
    end

    def do_next_job(context, queue)
      queue.pop.exec(context, queue)
    rescue Exception => e # rubocop:disable Lint/RescueException
      @trading_context.logger.error(e)
      context.fail(e) if @fail_on_error
    end

    def cancel
      return if finished?
      if running?
        post_exec { |c| c.request_cancel }.value
        sleep 0.1 until finished?
      else
        @trading_context.request_cancel
        @trading_context.post_running
      end
    end

    def pause
      return if finished?
      if running?
        post_exec { |c| c.request_pause }.value
        sleep 0.1 until finished?
      else
        @trading_context.request_pause
        @trading_context.post_running
      end
    end

    def post_exec(&block)
      job = Jiji::Model::Trading::Jobs::Job.create_from(&block)
      post_job(job).future
    end

    def post_job(job)
      if running?
        @job_queue.push(job)
      else
        job.exec(@trading_context, @job_queue)
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
