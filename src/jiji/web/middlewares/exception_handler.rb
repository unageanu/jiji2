# coding: utf-8

require 'sinatra/base'

module Jiji
module Web

  class ExceptionHandler < Sinatra::Base
    
    error Jiji::Errors::UnauthorizedException do
      status 401
    end
    
    error Jiji::Errors::NotFoundException do
      status 404
    end
    
    error Jiji::Errors::AuthFailedException do
      status 401
    end
    
    error do
      status 500
    end
    
  end

end
end