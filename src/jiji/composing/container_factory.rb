# coding: utf-8

require 'singleton'
require 'logger'
require 'fileutils'

require 'encase/container'

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all( "jiji" )

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
      configure_security( container )
      configure_model( container )
      configure_sources( container )
      configure_plugins( container )
      configure_logger( container )
    end
    
    def configure_web( container )
      container.configure do
        object :echo_service, Jiji::Web::EchoService.new
      end
    end
    
    def configure_security( container )
      container.configure do
        object :authenticator, Jiji::Security::Authenticator.new
        object :session_store, Jiji::Security::SessionStore.new
      end
    end
    
    def configure_model( container )
      container.configure do
        object :security_setting, Jiji::Model::Settings::SecuritySetting.load_or_create
      end
    end
    
    def configure_sources( container )
      container.configure do
        object :time_source, Jiji::Utils::TimeSource.new
      end
    end
    
    def configure_plugins( container )
      container.configure do
        object :plugin_loader, Jiji::Plugin::Loader.new
      end
    end
    
    def configure_logger( container )
      logger = Logger.new( STDOUT )
      logger.level = Logger::DEBUG
      container.configure do
        object :logger, logger
      end
    end
    
  end

end
end