# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class SecuritiesSettingService < Jiji::Web::AuthenticationRequiredService

    include Jiji::Model::Settings

    options '/available-securities' do
      allow('GET,OPTIONS')
    end

    get '/available-securities' do
      available_securities = securities_factory.available_securities.map do |p|
        { securities_id: p[:id], name: p[:display_name] }
      end
      ok(available_securities)
    end

    options '/available-securities/:securities_id/configuration_definitions' do
      allow('GET,OPTIONS')
    end

    get '/available-securities/:securities_id/configuration_definitions' do
      config = securities_factory.get(params['securities_id'].to_sym)
      ok(config[:configuration_definition])
    end

    options '/available-securities/:securities_id/configurations' do
      allow('GET,OPTIONS')
    end

    get '/available-securities/:securities_id/configurations' do
      ok(securities_setting.get_configurations(params['securities_id'].to_sym))
    end

    options '/active-securities/id' do
      allow('GET,OPTIONS')
    end

    get '/active-securities/id' do
      setting = securities_setting
      if setting.active_securities_id
        ok({ securities_id: setting.active_securities_id })
      else
        not_found
      end
    end

    options '/active-securities' do
      allow('PUT,OPTIONS')
    end

    put '/active-securities' do
      body = load_body
      securities_setting.set_active_securities(
        body['securities_id'].to_sym, body['configurations'])
      no_content
    end

    def securities_setting
      lookup(:setting_repository).securities_setting
    end

    def securities_factory
      lookup(:securities_factory)
    end

  end
end
