# coding: utf-8

require 'encase'
require 'json'
require 'jiji/web/middlewares/base'

module Jiji
module Web

  class AbstractService < Base
    
    include Jiji::Errors
    
    #use :protection
    
    set :sessions, false
    
  protected

    def load_body
      JSON.load(request.body)
    end

    def ok( body )
      [200, body.to_json]
    end
    
    def created( body )
      [201, body.to_json]
    end
    
    def no_content
      [204]
    end
    
    def not_found
      raise Jiji::Errors::NotFoundException.new
    end
    def illegal_state
      raise Jiji::Errors::IllegalStateException.new
    end
    def auth_failed
      raise Jiji::Errors::AuthFailedException.new
    end
    
  end
  
  class AuthenticationRequiredService < AbstractService 
    use Jiji::Web::AuthenticationFilter
  end

end
end