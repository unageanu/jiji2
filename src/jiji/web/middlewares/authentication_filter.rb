# coding: utf-8

require 'sinatra/base'
require 'jiji/web/middlewares/base'

module Jiji::Web
class AuthenticationFilter < Base
  
  before do
    unauthorized unless auth_success?
  end

private
  
  def auth_success?
    session_store.valid_token?( extract_token )
  end
  
  def extract_token
    a = request.env["HTTP_AUTHORIZATION"]
    if ( a =~ /X\-JIJI\-AUTHENTICATE\s+([a-f0-9]+)$/ )
      return $1
    else
      unauthorized
    end
  end
  
  def session_store
    lookup(:session_store)
  end
  
  def unauthorized
    raise Jiji::Errors::UnauthorizedException.new
  end
  
end
end