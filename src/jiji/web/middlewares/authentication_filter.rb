# coding: utf-8

require 'sinatra/base'

module Jiji
module Web

  class AuthenticationFilter < Sinatra::Base
    
    include Encase
    
    needs :session_store
    
    
    before %r{^(?!/authenticator$)} do
      unauthorized unless auth_success?
    end
    
    def auth_success?
      session_store.valid?( extract_ticket )
    end
    
    def extract_ticket
      a = request.env["Authorization"]
      if ( a =~ /X-JIJI-AUTHENTICATE\s([a-f0-9]+)$/ )
        return $1
      else
        unauthorized
      end
    end
    
    def unauthorized
      raise Jiji::Errors::UnauthorizedException.new
    end
    
  end

end
end