# coding: utf-8

require 'thread'
require 'jiji/errors/errors'

module Jiji::Model::Trading::Brokers
  class RMTBroker < AbstractBroker

    include Encase
    include Jiji::Errors
    include Jiji::Model::Trading

    needs :time_source
    needs :securities_provider
    needs :position_builder
    needs :position_repository

    def initialize
      super()
      @backtest_id = nil
    end

    def on_inject
      init_positions(position_repository.retrieve_living_positions_of_rmt)
    end

    def next?
      true
    end

    def refresh
      @pairs_cache = nil
      super
    end

    private

    def securities
      securities_provider.get
    end

  end
end
