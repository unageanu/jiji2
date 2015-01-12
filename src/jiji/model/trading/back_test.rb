# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'
require 'jiji/web/transport/transportable'

module Jiji
module Model
module Trading

  class BackTest
  
    include Encase
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Jiji::Errors
    include Jiji::Model::Trading
    
    needs :logger
    needs :time_source
    needs :back_test_thread_pool
    #needs :agents_factory
    
    store_in collection: "backtests"
    
    field :name,          type: String
    field :created_at,    type: Time
    field :memo,          type: String
        
    field :start_time,    type: Time
    field :end_time,      type: Time
    field :agent_setting, type: Hash
    
    index(
      { :created_at => 1, :id=> 1 }, 
      { unique: true, name: "backtests_created_at_id_index" })
    
    attr :process, :job, :borker, :agents
    
    def to_h
      { 
        :id   => _id,
        :name => name, 
        :memo => memo,
        :created_at => created_at,
        :start_time => start_time,
        :end_time   => end_time
      }
    end
    
    def self.create_from_hash(hash)
      BackTest.new {|b|
        b.name = hash["name"]
        b.memo = hash["memo"]
        b.start_time = hash["start_time"]
        b.end_time   = hash["end_time"]
      }
    end
    
    def setup
      self.created_at = time_source.now

      #@agents = agents_factory.create(agent_setting)
      @broker  = Brokers::BackTestBroker.new(start_time, end_time)
      @job     = Jobs::BackTestJob.new(@agents, @broker, @logger)
      @process = Processes::BackTestProcess.new(@job, back_test_thread_pool, logger)
      
      @process.start
    end
    
    def delete
      # TODO delete positions, logs
      super
    end
    
  private
    
  end

end
end
end
