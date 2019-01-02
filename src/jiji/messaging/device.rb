# frozen_string_literal: true

require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/trading/back_test'

module Jiji::Messaging
  class Device

    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    store_in collection: 'devices'

    field :uuid,         type: String
    field :server_url,   type: String
    field :model,        type: String
    field :platform,     type: String
    field :version,      type: String
    field :type,         type: Symbol
    field :device_token, type: String
    field :target_arn,   type: String

    index({ uuid: 1 }, { unique: true, name: 'devices_uuid_index' })

    def self.get_or_create_from_hash(hash)
      uuid = hash[:uuid]
      device = Device.find_by({ uuid: uuid }) || Device.new(uuid)
      device.update_from_hash(hash)
      device.save
      device
    end

    def initialize(uuid)
      super()
      self.uuid = uuid
    end

    def update_from_hash(hash)
      self.server_url   = hash[:server_url]
      self.model        = hash[:model]
      self.platform     = hash[:platform]
      self.version      = hash[:version]
      self.type         = hash[:type].to_sym
      self.device_token = hash[:device_token]
      self.target_arn   = hash[:target_arn]
    end

    def to_h
      {
        id:         id,
        uuid:       uuid,
        model:      model,
        platform:   platform,
        version:    version,
        type:       type,
        server_url: server_url
      }
    end

  end
end
