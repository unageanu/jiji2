# coding: utf-8

require 'sinatra/base'

module Jiji
module Web

  class EchoService < Sinatra::Base
    
    get "/" do
      "Hello"
    end
    
  end

end
end