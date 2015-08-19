# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class IconService < Jiji::Web::AuthenticationRequiredService

    options '/' do
      allow('GET,POST,OPTIONS')
    end
    get '/' do
      ok(repository.all.map { |icon| icon })
    end
    post '/' do
      illegal_argument unless params[:file]
      tempfile = params[:file][:tempfile]
      icon = File.open(tempfile.path) do |io|
        illegal_argument if io.size > 1024 * 1024 * 10
        # 10MB以上なら処理する前にエラーにする。
        repository.add(io.read)
      end
      ok(icon)
    end

    options '/:icon_id' do
      allow('GET,DELETE,OPTIONS')
    end
    get '/:icon_id' do
      ok(repository.get(icon_id))
    end
    delete '/:icon_id' do
      ok(repository.delete(icon_id))
    end

    options '/:icon_id/image' do
      allow('GET,OPTIONS')
    end
    get '/:icon_id/image' do
      [200, cacheable, get_icon_image]
    end

    def get_icon_image
      begin
        repository.get(icon_id).image
      rescue Jiji::Errors::NotFoundException, BSON::ObjectId::Invalid
        load_default_icon
      end
    end

    def icon_id
      BSON::ObjectId.from_string(params['icon_id'])
    end

    def load_default_icon
      @default_icon_data ||= File.open(default_icon_path) {|f| f.read }
    end

    def default_icon_path
      StaticFileService.static_file_dir + "/images/default-icon.png"
    end

    def repository
      lookup(:icon_repository)
    end

  end
end
