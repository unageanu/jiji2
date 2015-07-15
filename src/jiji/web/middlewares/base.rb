# coding: utf-8

require 'sinatra/base'
require 'jiji/errors/errors'
require 'active_model'

module Jiji::Web
  class Base < Sinatra::Base

    before do
      lookup(:time_source).set(Time.now)
    end
    after do
      lookup(:time_source).reset
    end

    def lookup(id)
      @cache ||= {}
      @cache[id] ||= WebApplication.instance.container.lookup(id)
    end

    def extract_token
      a = request.env['HTTP_AUTHORIZATION']
      if  a =~ /X\-JIJI\-AUTHENTICATE\s+([a-f0-9]+)$/
        return Regexp.last_match(1)
      else
        unauthorized
      end
    end

    error Jiji::Errors::UnauthorizedException do
      print_as_warning
      401
    end

    error Jiji::Errors::NotFoundException do
      print_as_warning
      404
    end

    error Jiji::Errors::AuthFailedException do
      print_as_warning
      401
    end

    error ArgumentError do |_e|
      print_as_warning
      400
    end

    error ActiveModel::StrictValidationFailed do |_e|
      print_as_warning
      400
    end

    error Jiji::Errors::IllegalStateException do |_e|
      print_as_warning
      400
    end

    error do
      print_as_error
      500
    end

    def print_as_warning
      logger.warn(env['sinatra.error'])
    end

    def print_as_error
      logger.error(env['sinatra.error'])
    end

    def logger
      @logger ||= lookup(:logger_factory).create_system_logger
    end

  end
end
