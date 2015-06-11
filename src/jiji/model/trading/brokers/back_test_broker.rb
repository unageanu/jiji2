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

    def initialize(backtest_id, start_time, end_time,
      pairs, balance, tick_repository)
      super()

      config = create_securities_configuration(
        backtest_id, start_time, end_time, pairs)
      @securities = VirtualSecurities.new(tick_repository, config)
      @backtest_id = backtest_id
      @position_builder = PositionBuilder.new(backtest_id)

      init_account(balance)
      init_positions
    end

    def destroy
    end

    def next?
      securities.next?
    end

    private

    def init_account(balance)
      @account = Account.new(nil, balance, 0.04)
    end

    def create_securities_configuration(
      backtest_id, start_time, end_time, pairs)
      {
        start_time:  start_time,
        end_time:    end_time,
        backtest_id: backtest_id,
        pairs:       pairs
      }
    end

  end
end
