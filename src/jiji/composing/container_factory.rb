# coding: utf-8

require 'singleton'
require 'logger'
require 'fileutils'
require 'thread/pool'
require 'encase/container'

require 'jiji/utils/requires'
Jiji::Utils::Requires.require_all('jiji')

class Jiji::Composing::ContainerFactory

  include Singleton

  include Jiji
  include Jiji::Model
  include Jiji::Security
  include Jiji::Web
  include Jiji::Db

  def new_container
    configure(Encase::Container.new)
  end

  private

  def configure(container)
    configure_web(container)
    configure_security(container)
    configure_trading_model(container)
    configure_setting_model(container)
    configure_agents_model(container)
    configure_model(container)
    configure_sources(container)
    configure_db(container)
    configure_plugins(container)
    configure_logger(container)
  end

  def configure_web(container)
    container.configure do
      object :echo_service,            EchoService.new

      object :initial_setting_service,    InitialSettingService.new
      object :rmt_broker_setting_service, RMTBrokerSettingService.new
      object :security_setting_service,   SecuritySettingService.new
    end
  end

  def configure_security(container)
    container.configure do
      object :authenticator, Authenticator.new
      object :session_store, SessionStore.new
    end
  end

  def configure_model(container)
    container.configure do
      object :application, Application.new
    end
  end

  def configure_trading_model(container)
    container.configure do
      object :position_repository,         Trading::PositionRepository.new

      object :tick_repository,             Trading::TickRepository.new
      object :rate_fetcher,                Trading::Internal::RateFetcher.new
    end
    configure_rmt_trading_model(container)
    configure_back_test_trading_model(container)
  end

  def configure_rmt_trading_model(container)
    container.configure do
      object :rmt,                         Trading::RMT.new
      object :rmt_broker,                  Trading::Brokers::RMTBroker.new
      object :rmt_next_tick_job_generator,
        Trading::Internal::RMTNextTickJobGenerator.new
    end
  end

  def configure_back_test_trading_model(container)
    container.configure do
      object :back_test_thread_pool,       Thread.pool(2)
      object :back_test_repository,        Trading::BackTestRepository.new
    end
  end

  def configure_setting_model(container)
    container.configure do
      object :security_setting,   Settings::SecuritySetting.load_or_create
      object :rmt_broker_setting, Settings::RMTBrokerSetting.load_or_create
    end
  end

  def configure_agents_model(container)
    container.configure do
      object :agent_source_repository,  Agents::AgentSourceRepository.new
      object :agent_registry,           Agents::AgentRegistry.new
    end
  end

  def configure_db(container)
    container.configure do
      object :index_builder, IndexBuilder.new
    end
  end

  def configure_sources(container)
    container.configure do
      object :time_source, Utils::TimeSource.new
    end
  end

  def configure_plugins(container)
    container.configure do
      object :plugin_loader, Plugin::Loader.new
    end
  end

  def configure_logger(container)
    logger = Logger.new(STDOUT) # TODO
    logger.level = Logger::DEBUG
    container.configure do
      object :logger, logger
    end
  end

end
