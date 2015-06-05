# coding: utf-8

require 'securerandom'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/errors/errors'

module Jiji::Model::Trading::Brokers
  class BackTestBroker < AbstractBroker

    include Jiji::Errors
    include Jiji::Model::Trading::Internal
    include Jiji::Model::Securities

    attr_reader :position_builder, :securities

    def initialize(backtest_id,
      start_time, end_time, pairs, tick_repository)
      super()

      @backtest_id = backtest_id

      @position_builder = PositionBuilder.new(backtest_id)
      @securities = VirtualSecurities.new(tick_repository, {
        start_time: start_time,
        end_time:   end_time,
        pairs:      pairs
      })

      init_positions
    end

    def destroy
    end

    def next?
      securities.next?
    end

  end
end
