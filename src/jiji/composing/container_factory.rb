# coding: utf-8

require 'singleton'

require 'encase/container'
require 'jiji/web/web_application'
require 'jiji/web/services/echo_service'

module Jiji
module Composing
  
  class ContainerFactory
    
    include Singleton
    
    def new_container
      return configure(Encase::Container.new)
    end

private
    
    def configure( container )
      configure_web( container )
    end
    
    def configure_web( container )
      container.configure do
        object :echo_service, Jiji::Web::EchoService.new
      end
    end
    
  end

end
end