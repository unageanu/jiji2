# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji::Model::Agents
  class Agents

    def initialize(agents = {}, logger=nil)
      @agents = agents
      @logger = logger
    end

    def next_tick(tick, broker)
      @agents.values.each do |a|
        begin
          a.next_tick(tick)
        rescue => e
          @logger.error(e) if @logger
        end
      end
    end

    def [](key)
      @agents[key]
    end

    def save_state
      @agents.each do |a|
        begin
          a.state
        rescue => e
          @logger.error(e)  if @logger
        end
      end
    end

  end
end
