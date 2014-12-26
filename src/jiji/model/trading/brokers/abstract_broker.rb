# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji
module Model
module Trading

  class AbstractBroker
    
    attr_accessor :positions
    
    def initialize
      @positions = {}
    end
    
    def available_pairs
      @pairs_cache ||= retrieve_pairs
    end
    
    def current_rates
      @rates_cache ||= retrieve_rates
    end
    
    def refresh
      @pairs_cache = nil
      @rates_cache = nil
    end
    
  protected
    
    
  end
  
end
end
end