# coding: utf-8

require 'securerandom'
require 'jiji/configurations/mongoid_configuration'

module Jiji
module Model
module Trading
module Brokers

  class BackTestBroker < AbstractBroker
    
    include Mongoid::Document
    
    def self.create
      BackTestBroker.new
    end
    def self.all
      BackTestBroker.find_by( :type => :backtest)
    end
    def self.get(id)
      BackTestBroker.find_by( :id => id, :type => :backtest )
    end
    
    attr_writer :start, :end
    
    def initialize
      @id   = @id || generate_id
      @type = :backtest
    end
    
    def positions
      # TODO
    end
    
    def buy( pair_id, count )
      # TODO
    end
    
    def sell( pair_id )
      # TODO
    end
    
    def destroy
    end
  
  protected
    def retrieve_pairs
      
    end
    def retrieve_rates
      @plugin ? @plugin.list_rates : {}
    end
  
  private
    def generate_id
       SecureRandom.uuid
    end
    
  end

end
end
end
end