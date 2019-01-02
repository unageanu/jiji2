# frozen_string_literal: true

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
      @migrator.migrate
      @index_builder.create_indexes
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
