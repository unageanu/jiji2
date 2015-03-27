# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'
require 'jiji/model/settings/rmt_broker_setting'

module Jiji::Web
  class RMTBrokerSettingService < Jiji::Web::AuthenticationRequiredService

    include Jiji::Model::Settings

    get '/available-securities' do
      available_securities = RMTBrokerSetting.available_securities.map do |p|
        { securities_id: p.plugin_id, name: p.display_name }
      end
      ok(available_securities)
    end

    get '/available-securities/:securities_id/configuration_definitions' do
      config = RMTBrokerSetting.get_configuration_definitions(
        params['securities_id'].to_sym)
      ok(config)
    end

    get '/available-securities/:securities_id/configurations' do
      ok(rmt_broker_setting.get_configurations(params['securities_id'].to_sym))
    end

    get '/active-securities/id' do
      setting = rmt_broker_setting
      if setting.active_securities_id
        ok({ securities_id: setting.active_securities_id })
      else
        not_found
      end
    end

    put '/active-securities' do
      body = load_body
      rmt_broker_setting.set_active_securities(
        body['securities_id'].to_sym, body['configurations'])
      no_content
    end

    def rmt_broker_setting
      lookup(:setting_repository).rmt_broker_setting
    end

  end
end
