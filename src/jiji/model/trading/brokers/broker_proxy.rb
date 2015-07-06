# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'forwardable'

module Jiji::Model::Trading::Brokers
  class BrokerProxy

    extend Forwardable

    def_delegators :@broker, :pairs, :tick, :positions, :orders,
      :modify_order, :cancel_order, :modify_position, :close_position

    attr_reader :agent_name, :agent_id

    def initialize(broker, agent_name, agent_id)
      @broker     = broker
      @agent_name = agent_name
      @agent_id   = agent_id
    end

    def buy(pair_name, units, type = :market, options = {})
      @broker.buy(pair_name, units, type, options, @agent_name, @agent_id)
    end

    def sell(pair_name, units, type = :market, options = {})
      @broker.sell(pair_name, units, type, options, @agent_name, @agent_id)
    end

  end
end
