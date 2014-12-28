# coding: utf-8

require 'sinatra/base'
require 'json'

module Jiji
module Web

  class RMTBrokerSettingService < Jiji::Web::AuthenticationRequiredService
    
    RMTBrokerSetting = Jiji::Model::Settings::RMTBrokerSetting
    
    get "/available-securities" do
      ok( RMTBrokerSetting.available_securities.map {|p|
        {:securities_id=>p.plugin_id, :name=>p.display_name}
      })
    end
    
    get "/:securities_id/configuration_definitions" do
      ok( RMTBrokerSetting.get_configuration_definitions(params["securities_id"].to_sym))
    end
    
    get "/:securities_id/configurations" do
      ok( setting.get_configurations(params["securities_id"].to_sym))
    end
    
    get "/active-securities/id" do
      if (setting.active_securities)
        ok( setting.active_securities.plugin_id )
      else
        not_found
      end
    end
    
    put "/active-securities" do
      body = load_body
      setting.set_active_securities(body["securities_id"].to_sym, body["configurations"])
      setting.save
      no_content
    end
    
    def setting
      lookup(:rmt_broker_setting)
    end
    
  end

end
end