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

    get '/:securities_id/configuration_definitions' do
      config = RMTBrokerSetting.get_configuration_definitions(
        params['securities_id'].to_sym)
      ok(config)
    end

    get '/:securities_id/configurations' do
      ok(setting.get_configurations(params['securities_id'].to_sym))
    end

    get '/active-securities/id' do
      if setting.active_securities
        ok(setting.active_securities.plugin_id)
      else
        not_found
      end
    end

    put '/active-securities' do
      body = load_body
      setting.set_active_securities(
        body['securities_id'].to_sym, body['configurations'])
      no_content
    end

    def setting
      lookup(:rmt_broker_setting)
    end
  end
end
