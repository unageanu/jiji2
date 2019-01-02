# frozen_string_literal: true

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

    def icon_id
      BSON::ObjectId.from_string(params['icon_id'])
    end

    def repository
      lookup(:icon_repository)
    end

  end
end
