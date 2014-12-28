# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji
module Web

  class InitialSettingService < Jiji::Web::AbstractService
    
    get "/initialized" do
      ok( :initialized => setting.password_setted? )
    end
    
    put "/password" do
      illegal_state if setting.password_setted?
      
      setting.password = load_body["password"]
      setting.save
      no_content
    end
    
    def setting
      lookup(:security_setting)
    end
    
  end

end
end