# coding: utf-8

require 'encase'

require 'jiji/composing/container_factory'

module Jiji::Model
  class Application

    include Encase

    needs :rmt
    needs :backtest_repository
    needs :index_builder
    needs :logger_factory
    needs :migrator

    def setup
      @index_builder.create_indexes
      @migrator.migrate
      @rmt.setup
      @backtest_repository.load
    end

    def tear_down
      @rmt.tear_down
      @backtest_repository.stop
      @logger_factory.close
    end

  end
end
