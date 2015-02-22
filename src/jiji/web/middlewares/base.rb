# coding: utf-8

require 'sinatra/base'
require 'jiji/errors/errors'

module Jiji::Web
class Base < Sinatra::Base
  
  # TODO 
  # X-Frame-Options
  # X-CONTENT-TYPE-OPTIONS: NOSNIFF
  # 
  
  before do
    lookup(:time_source).set( Time.now )
  end
  after do
    lookup(:time_source).reset
  end
  
  def lookup(id)
    @cache ||= {}
    @cache[id] ||= WebApplication.instance.container.lookup(id)
  end
  
  error Jiji::Errors::UnauthorizedException do
    401
  end
  
  error Jiji::Errors::NotFoundException do
    404
  end
  
  error Jiji::Errors::AuthFailedException do
    401
  end
  
  error ArgumentError do
    400
  end
  
  error do
    500
  end
  
end
end