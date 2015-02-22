# coding: utf-8

require 'jiji/plugin/securities_plugin'

module Jiji
module Test 
module Mock

  class MockBackTest
    def job
      MockJob.new
    end
  end
  
  # class MockJob < Jiji::Model::Trading::Jobs::AbstractJob
    # def do_next
      # sleep 0.1
    # end
    # def has_next
      # @status == :running
    # end
    # def before_do_next
    # end
  # end
  
end
end
end