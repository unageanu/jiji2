# coding: utf-8

require 'encase'
require 'json'
require 'time'
require 'jiji/web/middlewares/base'
require 'jiji/web/middlewares/authentication_filter'
require 'jiji/web/transport/json'

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
    def get_time_from_query_parm(key)
      if request[key] == nil 
        illegal_argument( "illegal argument. key=#{key}" )
      end 
      Time.parse(request[key])
    end
    
    def serialize(body)
      JSON.generate(body)
    end

    def ok( body )
      content_type "application/json"
      [200, serialize(body)]
    end
    
    def created( body )
      content_type "application/json"
      [201, serialize(body)]
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
    def illegal_argument( message )
      raise ArgumentError.new(message)
    end
  end
  
  class AuthenticationRequiredService < AbstractService 
    use Jiji::Web::AuthenticationFilter
  end

end
end