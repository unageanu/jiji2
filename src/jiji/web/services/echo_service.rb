# coding: utf-8

require 'sinatra/base'

module Jiji
module Web

  class EchoService < Jiji::Web::AbstractService
    
    get "/" do
      "Hello"
    end
    
  end

end
end