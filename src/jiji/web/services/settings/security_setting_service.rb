# coding: utf-8

require 'sinatra/base'
require 'json'

module Jiji
module Web

  class SecuritySettingService < Jiji::Web::AuthenticationRequiredService
    
    put "/password" do
      body = load.body
      if setting.validate_password(body["old_password"])
        setting.password = body["password"]
        setting.save
        no_content
      else
        auth_failed
      end
    end
    
    def setting
      lookup(:security_setting)
    end
    
  end

end
end