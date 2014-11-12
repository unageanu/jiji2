# coding: utf-8

require 'sinatra/base'

module Jiji
module Web

  class AbstractService < Sinatra::Base
    
    include Encase
    
    use Jiji::Web::AuthenticationFilter
    use Jiji::Web::ExceptionHandler
    
    #use :protection
    
  end

end
end