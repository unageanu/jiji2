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

    def initialize
      super()
      @back_test_id = nil
      @securities   = nil
      @mutex = Mutex.new
    end

    def next?
      true
    end

    def positions
      check_setting_finished
      super
    end

    def buy(pair_id, units)
      internal_id = order(pair_id, :buy, units)
      create_position(pair_id, units, :buy,  internal_id)
    end

    def sell(pair_id, units)
      internal_id = order(pair_id, :sell, units)
      create_position(pair_id, units, :sell,  internal_id)
    end

    def destroy
      securities.destroy if securities
    end

    def securities
      securities_provider.get
    end

    def refresh
      @pairs_cache = nil
      super
    end

    private

    def retrieve_pairs
      securities.retrieve_pairs
    end

    def retrieve_tick
      securities.retrieve_current_tick
    end

    def order(pair_id, type, units)
      check_setting_finished
      position = securities.order(pair_id, type, units)
      position.position_id
    end

    def do_close(position)
      check_setting_finished
      securities.commit(position.internal_id, position.units)
    end

    def check_setting_finished
      fail Jiji::Errors::NotInitializedException unless securities
    end

  end
end
