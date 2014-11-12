# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'bcrypt'

module Jiji
module Security

  class Authenticator
    
    include Encase

    needs :security_setting
    needs :session_store
    needs :time_source
    
    def authenticate( hashed_password )
      unless validate_hashed_password( hashed_password )
        raise Jiji::Errors::AuthFailedException.new
      end
      return new_session.token
    end

  private 
  
    def validate_hashed_password( hashed_password )
      return hashed_password == security_setting.hashed_password
    end
    
    def new_session
       session = Jiji::Security::Session.new( expiration_date )
       session_store << session
       return session
    end
    
    def expiration_date
       time_source.now + security_setting.expiration_days
    end
    
  end

end
end