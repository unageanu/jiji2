# coding: utf-8

require 'encase'
require 'thread'

module Jiji::Model::Trading
class TradingContext
  
  attr :broker
  attr :agents
  attr :status
  attr :logger
  attr :error
  attr :variables
  attr :time_source
  
  def initialize( agents, broker, time_source, logger )
    @logger      = logger
    @time_source = time_source
    @agents      = agents || Jiji::Model::Agents::Agents.new #TODO
    @broker      = broker
    @status      = :wait_for_start
    @error       = nil
    @variables   = {}
  end
  
  def prepare_running 
    @status = :running
  end
  
  def post_running
    @status = @status == :wait_for_cancel ? :cancelled : :finished
  end
  
  def fail( error )
    @status = :error
    @error  = error
  end
  
  def request_cancel
    @status = :wait_for_cancel
  end

  def alive?
    @status == :running
  end
  
  def [](key)
   @variables[key]
  end
  def []=(key, value)
   @variables[value]
  end
  
end
end
