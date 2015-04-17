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
      register_services(builder)
      register_setting_services(builder)
      register_testing_services(builder)
      register_static_files(builder)
      register_root(builder)
      builder
    end

    attr_reader :container

    private

    def register_services(builder)
      builder.map('/api/echo')          { run EchoService }
      builder.map('/api/rates')         { run RateService }
      builder.map('/api/authenticator') { run AuthenticationService }
    end

    def register_setting_services(builder)
      base = '/api/setting'
      builder.map("#{base}/initialization")    { run InitialSettingService }
      builder.map("#{base}/rmt-broker")        { run RMTBrokerSettingService }
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
