# coding: utf-8

require 'rack'

require 'jiji/composing/container_factory'

module Jiji
module Web
  
  class WebApplication
    
    def initialize
      @container = Jiji::Composing::ContainerFactory.instance.new_container
    end
      
    def build
      echo_service = container.lookup(:echo_service)
      return Rack::Builder.new do
        map( "/echo" ) { run echo_service }
      end
    end
    
    attr_reader :container
  end

end
end