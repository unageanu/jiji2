# coding: utf-8

require 'encase'
require 'lru_redux'

module Jiji::Model::Icons
  class IconRepository

    include Encase

    needs :imaging_service
    needs :time_source

    def initialize
      @cache = LruRedux::ThreadSafeCache.new(100)
    end

    def all
      Icon.only(:id, :created_at).order_by(:created_at.asc)
    end

    def get(id)
      icon = @cache[id]
      return icon if icon
      icon = Icon.find(id) || not_found(Icon, id:id)
      @cache[id] = icon
      return icon
    end

    def add(image)
      icon_data = BSON::Binary.new(imaging_service.create_icon(image))
      icon = Icon.new(time_source.now, icon_data)
      icon.save
      icon
    end

  end
end
