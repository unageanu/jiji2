# coding: utf-8

require 'encase'
require 'jiji/model/trading/jobs/abstract_job'

module Jiji::Model::Trading::Jobs
class BackTestJob < AbstractJob
  
  def initialize(agents, broker, logger)
    super()
    @agents = agents || @agents
    @broker = broker
    @logger = logger
  end
  
end
end
