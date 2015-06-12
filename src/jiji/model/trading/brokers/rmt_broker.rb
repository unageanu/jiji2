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
      securities_provider.add_observer self

      init_account
      init_positions(position_repository.retrieve_living_positions_of_rmt)

      # rubocop:disable Lint/HandleExceptions
      begin
        positions = securities.retrieve_trades
        @positions.update(positions)
      rescue Jiji::Errors::NotInitializedException
      end
      # rubocop:enable Lint/HandleExceptions
    end

    def next?
      true
    end

    # for internal use.
    def refresh_account
      init_account
    end

    def update(ev)
      @pairs_cache = nil
      @rates_cache = nil

      init_account
      reload_positions
      @orders_is_dirty = true
    end

    private

    def init_account
      @account = securities.retrieve_account
    rescue Jiji::Errors::NotInitializedException
      @account = Account.new(nil, 0, 0.04)
    end

    # rubocop:disable Lint/HandleExceptions
    def reload_positions
      positions = securities.retrieve_trades
      @positions.replace(positions, @account)
      @positions.update_price(tick, pairs)
      @positions_is_dirty = false
      @positions.each { |p| p.attach_broker(self) }
    rescue Jiji::Errors::NotInitializedException
    end
    # rubocop:enable Lint/HandleExceptions

    def securities
      securities_provider.get
    end

  end
end
