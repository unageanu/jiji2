# frozen_string_literal: true

require 'securerandom'
require 'set'
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
      interval_id, pairs, balance, orders, modules)
      super()

      positions =
        modules[:position_repository].retrieve_living_positions(backtest.id)

      build_components(backtest, start_time,
        end_time, interval_id, pairs, orders, positions, modules)
      init_account(balance)
      init_positions(positions)
    end

    def destroy; end

    def next?
      securities.next?
    end

    def resolve_required_pairs(pairs, modules)
      resolver = Jiji::Model::Trading::Utils::CounterPairResolver.new
      pairs.each_with_object(Set.new(pairs)) do |pair, set|
        resolver.resolve_required_pairs(
          modules[:pairs], pair.name, @account_currency).each do |name|
          set << modules[:pairs].get_by_name(name)
        end
      end.to_a
    end

    private

    def build_components(backtest, start_time, end_time,
      interval_id, pairs, orders, positions, modules)
      @account_currency = modules[:securities_provider].get.account_currency
      config = create_securities_configuration(backtest,
        start_time, end_time, interval_id, pairs, orders, positions, modules)
      @securities = VirtualSecurities.new(
        modules[:tick_repository], modules[:securities_provider], config)
      @backtest_id = backtest.id

      @position_builder = PositionBuilder.new(backtest)
    end

    def init_account(balance)
      @account = Account.new(nil, @account_currency, balance, 0.04)
    end

    def create_securities_configuration(backtest,
      start_time, end_time, interval_id, pairs, orders, positions, modules)
      {
        start_time:  start_time,
        end_time:    end_time,
        interval_id: interval_id,
        backtest:    backtest,
        pairs:       resolve_required_pairs(pairs, modules),
        orders:      orders,
        positions:   positions
      }
    end

  end
end
