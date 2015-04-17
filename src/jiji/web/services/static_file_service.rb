# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'
require 'jiji/utils/requires'

module Jiji::Web
  class StaticFileService < Jiji::Web::AbstractService

    def self.static_file_dir
      dir = (ENV['RACK_ENV'] == 'test') ? '/apps' : '/minified'
      Jiji::Utils::Requires.root + '/sites/build' + dir
    end

    set :public_folder, StaticFileService.static_file_dir
    set :static_cache_control, [:public, max_age: 60 * 60 * 24 * 365]

    get /\/v([a-zA-Z0-9\-\_\.]+)\/(.*)/ do
      redirect to(params['captures'][1])
    end

  end
end
