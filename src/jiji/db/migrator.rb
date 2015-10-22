# coding: utf-8
require 'encase'
require 'mongoid'
require 'jiji/configurations/mongoid_configuration'

module Jiji::Db
  class Migrator

    include Encase

    needs :logger_factory
    needs :v0to1_register_system_agent

    def initialize
      @scripts = []
    end

    def on_inject
      register_script @v0to1_register_system_agent
    end

    def migrate
      status = SchemeStatus.load
      logger = @logger_factory.create
      @scripts.each do |s|
        run_script(s, status, logger)
      end
    end

    def register_script(script)
      @scripts << script
    end

    private

    def run_script(script, status, logger)
      return if status.applied? script.id
      script.call(status, logger)
      status.mark_as_applied(script.id)
      status.save
    rescue => e
      logger.error(e)
    end

  end
end
