# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class PairSettingService < Jiji::Web::AuthenticationRequiredService

    options '/' do
      allow('GET,PUT,OPTIONS')
    end

    get '/' do
      ok(setting.pairs_for_use)
    end

    put '/' do
      body = load_body
      pair_setting = setting
      pair_setting.pair_names = body.map { |pair| pair['name'] }
      pair_setting.save
      no_content
    end

    options '/all' do
      allow('GET,OPTIONS')
    end

    get '/all' do
      ok(pairs.all)
    end

    def setting
      lookup(:setting_repository).pair_setting
    end

    def pairs
      lookup(:pairs)
    end

  end
end
