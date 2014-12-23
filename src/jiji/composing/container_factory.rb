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
    
    include Jiji
    include Jiji::Model
    include Jiji::Security
    include Jiji::Web
    
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
        object :echo_service, EchoService.new
      end
    end
    
    def configure_security( container )
      container.configure do
        object :authenticator, Authenticator.new
        object :session_store, SessionStore.new
      end
    end
    
    def configure_model( container )
      container.configure do
        object :security_setting,   Settings::SecuritySetting.load_or_create
        object :rmt_broker_setting, Settings::RMTBrokerSetting.load_or_create
        
        object :rmt_process,      Trading::RMTProcess.new
        object :rmt_job,          Trading::Jobs::RMTJob.new
        object :rmt_broker,       Trading::Brokers::RMTBroker.new
      end
    end
    
    def configure_sources( container )
      container.configure do
        object :time_source, Utils::TimeSource.new
      end
    end
    
    def configure_plugins( container )
      container.configure do
        object :plugin_loader, Plugin::Loader.new
      end
    end
    
    def configure_logger( container )
      logger = Logger.new( STDOUT ) # TODO
      logger.level = Logger::DEBUG
      container.configure do
        object :logger, logger
      end
    end
    
  end

end
end