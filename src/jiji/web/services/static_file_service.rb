# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'
require 'jiji/utils/requires'

module Jiji::Web
  class StaticFileService < Jiji::Web::AbstractService

    def self.static_file_dir
      dir = (ENV['RACK_ENV'] == 'production') ? '/minified' : '/apps'
      Jiji::Utils::Requires.root + '/sites/build' + dir
    end

    set :public_folder, StaticFileService.static_file_dir
    set :static_cache_control, [:public, max_age: 60 * 60 * 24 * 365]

    get %r{(.*/)v([a-zA-Z0-9\-\_\.]+)/(.*)} do
      path = params['captures'][0] + params['captures'][2]
      call env.merge('PATH_INFO' => path)
    end

  end
end
