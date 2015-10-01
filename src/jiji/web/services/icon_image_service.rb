# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class IconImageService < Jiji::Web::AbstractService

    options '/:icon_id' do
      allow('GET,OPTIONS')
    end
    get '/:icon_id' do
      content_type 'image/png'
      [200, cacheable.merge({}), load_icon_image]
    end

    def load_icon_image
      repository.get(icon_id).image.data
    rescue Jiji::Errors::NotFoundException, BSON::ObjectId::Invalid
      load_default_icon
    end

    def icon_id
      BSON::ObjectId.from_string(params['icon_id'])
    end

    def load_default_icon
      @default_icon_data ||= File.open(default_icon_path) { |f| f.read }
    end

    def default_icon_path
      StaticFileService.static_file_dir + '/images/default-icon.png'
    end

    def repository
      lookup(:icon_repository)
    end

  end
end
