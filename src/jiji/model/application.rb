# coding: utf-8

require 'encase'

require 'jiji/composing/container_factory'

module Jiji::Model
  class Application

    include Encase

    needs :rmt
    needs :backtest_repository
    needs :index_builder

    def setup
      @index_builder.create_indexes
      @rmt.setup
    end

    def tear_down
      @rmt.tear_down
      @backtest_repository.stop
    end

  end
end
