# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji::Model::Agents
class Agents
  
  def initialize(agents=[])
    @agents = agents
  end
  
  def next_tick( broker )
    @agents.each {|a|
      begin
        a.next_tick( broker )
      rescue => e
        @logger.error(e)
      end
    }
  end
  
  def << (agent)
    @agents << agent
  end
  
  def save_state
    @agents.each {|a|
      begin
        a.save_state
      rescue => e
        @logger.error(e)
      end
    }
  end
  
end
end