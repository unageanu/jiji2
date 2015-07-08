# coding: utf-8

require 'rack'
require 'singleton'
require 'jiji/composing/container_factory'

module Jiji::Web
  class WebApplication

    include Singleton

    def initialize
      @container = Jiji::Composing::ContainerFactory.instance.new_container
      setup
    end

    def setup
      @application = @container.lookup(:application)
      @application.setup
      app = @application
      at_exit do
        app.tear_down
      end
    end

    def build
      builder = Rack::Builder.new
      register_base_services(builder)
      register_trading_services(builder)
      register_authentication_service(builder)
      register_setting_services(builder)
      register_testing_services(builder)
      register_static_files(builder)
      register_root(builder)
      builder
    end

    attr_reader :container

    private

    def register_base_services(builder)
      builder.map('/api/echo')          { run EchoService }
      builder.map('/api/agents')        { run AgentService }
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
      builder.map('/api/authenticator') { run AuthenticationService }
      builder.map('/api/sessions')      { run SessionService }
    end

    def register_setting_services(builder)
      base = '/api/settings'
      builder.map("#{base}/initialization")    { run InitialSettingService }
      builder.map("#{base}/securities")        { run SecuritiesSettingService }
      builder.map("#{base}/user")              { run UserSettingService }
      builder.map("#{base}/password-resetter") { run PasswordResettingService }
    end

    def register_testing_services(builder)
      return unless (ENV['RACK_ENV'] == 'test')
      builder.map('/api/testing/mail') { run Test::MailService  }
    end

    def register_static_files(builder)
      builder.map('/static/')          { run StaticFileService }
    end

    def register_root(builder)
      builder.map('/') { run RootService }
    end

  end
end
