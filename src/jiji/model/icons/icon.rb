# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/trading/back_test'

module Jiji::Model::Icons
  class Icon

    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    store_in collection: 'icons'

    field :image,       type: BSON::Binary
    field :created_at,  type: Time

    index(
      { created_at: 1 },
      name: 'icon_created_at_index')

    def initialize(created_at, image)
      super()
      self.created_at       = created_at
      self.image            = image
    end

    def to_h
      {
        id:               id,
        created_at:       created_at
      }
    end

  end
end
