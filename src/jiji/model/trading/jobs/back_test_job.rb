# coding: utf-8

require 'encase'
require 'jiji/model/trading/jobs/abstract_job'

module Jiji
module Model
module Trading
module Jobs

  class BackTestJob < AbstractJob
    
    def initialize(agents, broker, logger)
      super()
      @agents = agents || @agents
      @broker = broker
      @logger = logger
    end
    
  end 

end
end
end
end
