# coding: utf-8

require 'thread'
require 'securerandom'
require 'jiji/model/trading/processes/abstract_process'

module Jiji
module Model
module Trading
module Processes
  
  class BackTestProcess < AbstractProcess
    
    attr :back_test
    
    def initialize(back_test, pool, logger)
      super back_test.job, pool, logger
      @back_test = back_test
    end
    
  end

end
end
end
end
