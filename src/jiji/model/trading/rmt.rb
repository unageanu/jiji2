# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
class RMT

  include Encase
  include Jiji::Errors
  include Jiji::Model::Trading
  
  needs :logger
  needs :time_source
  needs :rmt_broker_setting
  needs :rmt_broker
  needs :rmt_next_tick_job_generator
  #needs :agents_factory
  
  attr :process, :trading_context
  
  def setup
    @rmt_broker_setting.setup
    setup_rmt_process
  end
  
  def tear_down
    stop_rmt_process
  end

private
  def setup_rmt_process
    #@agents         = agents_factory.create(agent_setting)
    @trading_context = TradingContext.new(@agents, rmt_broker, time_source, logger)
    @process         = Process.new(trading_context, Thread.pool(1), false)
    
    @process.start
    @rmt_next_tick_job_generator.start( @process.job_queue )
  end
  
  def stop_rmt_process
    @rmt_next_tick_job_generator.stop
    @process.stop
  end
end
end
