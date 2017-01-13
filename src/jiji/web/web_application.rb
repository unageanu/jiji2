# coding: utf-8

require 'rack'
require 'singleton'
require 'jiji/composing/container_factory'
require 'thread'

module Jiji::Web
  class WebApplication

    include Singleton

    def initialize
      @container = Jiji::Composing::ContainerFactory.instance.new_container
      @exit_action_queue = Queue.new
      @future = Jiji::Utils::Future.new
      setup
    end

    def setup
      @application = @container.lookup(:application)
      @application.setup
      @rpc_server = @container.lookup(:rpc_server)
      @rpc_server.start
      start_cleanup_thread(@application, @rpc_server)
      trap(0) do
        @exit_action_queue << true
        @future.value
      end
    end

    def start_cleanup_thread(application, rpc_server)
      Thread.new(application, rpc_server) do |app, rpc|
        loop do
          break unless @exit_action_queue.pop
          cleanup(app, rpc)
        end
      end
    end

    def cleanup(app, rpc)
      app.tear_down
      rpc.stop

      @future.value = true
    rescue => e
      @future.error = e
    end

    def build
      builder = Rack::Builder.new
      register_apis(builder)
      register_static_files(builder)
      register_root(builder)
      builder
    end

    attr_reader :container

    private

    def register_apis(builder)
      register_base_services(builder)
      register_icon_services(builder)
      register_trading_services(builder)
      register_authentication_service(builder)
      register_setting_services(builder)
      register_download_service(builder)
      register_testing_services(builder)
    end

    def register_base_services(builder)
      builder.map('/api/echo')          { run EchoService }
      builder.map('/api/agents')        { run AgentService }
      builder.map('/api/logs')          { run LogService }
      builder.map('/api/actions')       { run ActionService }
      builder.map('/api/notifications') { run NotificationService }
      builder.map('/api/devices')       { run DeviceService }
      builder.map('/api/version')       { run VersionService }
    end

    def register_icon_services(builder)
      builder.map('/api/icons')         { run IconService }
      builder.map('/api/icon-images')   { run IconImageService }
    end

    def register_trading_services(builder)
      builder.map('/api/rates')             { run RateService }
      builder.map('/api/rmt')               { run RMTService }
      builder.map('/api/backtests')         { run BacktestService }
      builder.map('/api/graph')             { run GraphService }
      builder.map('/api/positions')         { run PositionsService }
      builder.map('/api/trading-summaries') { run TradingSummariesService }
    end

    def register_authentication_service(builder)
      builder.map('/api/authenticator')  { run AuthenticationService }
      builder.map('/api/sessions')       { run SessionService }
      builder.map('/api/onetime-tokens') { run OneTimeTokenService }
    end

    def register_setting_services(builder)
      base = '/api/settings'
      builder.map("#{base}/initialization")    { run InitialSettingService }
      builder.map("#{base}/securities")        { run SecuritiesSettingService }
      builder.map("#{base}/user")              { run UserSettingService }
      builder.map("#{base}/password-resetter") { run PasswordResettingService }
      builder.map("#{base}/smtp-server")       { run SMTPServerSettingService }
      builder.map("#{base}/pairs")             { run PairSettingService }
    end

    def register_download_service(builder)
      builder.map('/api/positions/download') { run PositionDownloadService }
    end

    def register_testing_services(builder)
      return unless ENV['RACK_ENV'] == 'test'
      builder.map('/api/testing/mail') { run Test::MailService }
    end

    def register_static_files(builder)
      builder.map('/static/')          { run StaticFileService }
    end

    def register_root(builder)
      builder.map('/') { run RootService }
    end

  end
end
