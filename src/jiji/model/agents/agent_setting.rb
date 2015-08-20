# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Agents
  class AgentSetting

    include Mongoid::Document
    include Jiji::Web::Transport::Transportable

    store_in collection: 'agent-settings'

    belongs_to :backtest, {
      class_name: 'Jiji::Model::Trading::BackTestProperties'
    }
    has_many :position, {
      class_name: 'Jiji::Model::Trading::Position',
      dependent:  :destroy
    }
    has_many :notification, {
      class_name: 'Jiji::Model::Notification::Notification',
      dependent:  :destroy
    }

    field :agent_class,    type: String
    field :name,           type: String
    field :icon_id,        type: BSON::ObjectId
    field :properties,     type: Hash
    field :active,         type: Boolean, default: true
    field :state,          type: Hash,    default: nil

    def self.get_or_create(id)
      setting = AgentSetting.find(id) if id
      return setting if setting

      return AgentSetting.new
    end

    def self.get_or_create_from_hash(hash)
      setting = AgentSetting.get_or_create(create_id_or_nil(hash[:id]))
      setting.agent_class = hash[:agent_class]
      setting.name        = hash[:agent_name]
      setting.icon_id     = create_id_or_nil(hash[:icon_id])
      setting.properties  = hash[:properties] || {}
      setting
    end

    def self.load(backtest_id=nil)
      AgentSetting
        .where({backtest_id:backtest_id, active: true})
        .order_by({name: :asc, id: :asc})
    end

    def display_info
      {
        id:      id,
        name:    name,
        icon_id: icon_id
      }
    end

    def to_h
      {
        id:          id,
        name:        name,
        agent_class: agent_class,
        icon_id:     icon_id,
        properties:  properties
      }
    end

    def self.create_id_or_nil(id)
      id ? BSON::ObjectId.from_string(id) : nil
    end

  end
end
