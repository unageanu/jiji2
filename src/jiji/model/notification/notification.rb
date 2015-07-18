# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/errors/errors'
require 'jiji/web/transport/transportable'

module Jiji::Model::Notification
  class Notification

    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Jiji::Errors

    store_in collection: 'notifications'
    belongs_to :backtest, {
      class_name: 'Jiji::Model::Trading::BackTestProperties'
    }

    field :agent_id,      type: String
    field :agent_name,    type: String
    field :actions,       type: Array
    field :icon,          type: String
    field :message,       type: String
    field :timestamp,     type: Time
    field :read_at,       type: Time

    index(
      { backtest_id: 1, timestamp: -1 },
      name: 'notification_backtest_id_timestamp_index')

    def self.create(agent_id, agent_name, timestamp,
      backtest_id = nil, message = '', icon = nil, actions = [])
      Notification.new do |n|
        n.timestamp   = timestamp
        n.initialize_agent_information(agent_id, agent_name, backtest_id)
        n.initialize_content(message, icon, actions)
      end
    end

    def read(timestamp)
      self.read_at = timestamp
      save
    end

    def read?
      !read_at.nil?
    end

    def to_h
      hash = {
        timestamp: timestamp,
        read_at:   read_at
      }
      insert_content_to_hash(hash)
      insert_agent_information_to_hash(hash)
      hash
    end

    def initialize_agent_information(agent_id, agent_name, backtest_id)
      self.agent_id    = agent_id
      self.agent_name  = agent_name
      self.backtest_id = backtest_id
    end

    def initialize_content(message = '', icon = nil, actions = [])
      self.message     = message
      self.icon        = icon
      self.actions     = actions
    end

    private

    def insert_content_to_hash(hash)
      hash[:message] = message
      hash[:icon]    = icon
      hash[:actions] = actions
    end

    def insert_agent_information_to_hash(hash)
      hash[:agent_id]    = agent_id
      hash[:agent_name]  = agent_name
      hash[:backtest_id] = backtest_id
    end

  end
end
