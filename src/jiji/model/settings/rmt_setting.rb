# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class RMTSetting < AbstractSetting

    include Encase
    include Mongoid::Document

    field :agent_setting,       type: Array,   default: []
    field :is_trade_enabled,    type: Boolean, default: true

    def initialize
      super
      self.category = :rmt
    end

  end
end
