# coding: utf-8

require 'securerandom'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/errors/errors'
require 'jiji/model/trading/brokers/abstract_broker'

module Jiji::Model::Trading::Brokers
  class BackTestBroker < AbstractBroker

    include Jiji::Errors
    include Jiji::Model::Trading::Internal
    include Jiji::Model::Securities

    attr_reader :position_builder, :securities

    def initialize(backtest, start_time, end_time,
      pairs, balance, orders, tick_repository, position_repository)
      super()

      positions = position_repository.retrieve_living_positions(backtest.id)
      config = create_securities_configuration(
        backtest, start_time, end_time, pairs, orders, positions)
      @securities = VirtualSecurities.new(tick_repository, config)
      @backtest_id = backtest.id

      @position_builder = PositionBuilder.new(backtest)

      init_account(balance)
      init_positions(positions)
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
      backtest, start_time, end_time, pairs, orders, positions)
      {
        start_time:  start_time,
        end_time:    end_time,
        backtest:    backtest,
        pairs:       pairs,
        orders:      orders,
        positions:   positions
      }
    end

  end
end
