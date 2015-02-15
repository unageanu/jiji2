# coding: utf-8

require 'thread/pool'
require 'securerandom'
require 'jiji/model/trading/processes/abstract_process'

module Jiji::Model::Trading::Processes
class RMTProcess < AbstractProcess
  
  include Encase
  
  needs :rmt_job
  needs :logger
  
  def initialize
    super(nil, Thread.pool(1), nil)
  end
  
  def on_inject
    @job = @rmt_job 
  end
  
end
end
