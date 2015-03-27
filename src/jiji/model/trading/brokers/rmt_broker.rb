# coding: utf-8

require 'thread'
require 'jiji/errors/errors'

module Jiji::Model::Trading::Brokers
  class RMTBroker < AbstractBroker

    include Encase
    include Jiji::Errors
    include Jiji::Model::Trading

    needs :time_source

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

    def buy(pair_id, count = 1)
      external_position_id = order(pair_id, :buy, count)
      create_position(pair_id, count, :buy,  external_position_id)
    end

    def sell(pair_id, count = 1)
      external_position_id = order(pair_id, :sell, count)
      create_position(pair_id, count, :sell,  external_position_id)
    end

    def destroy
      securities.destroy_plugin if securities
    end

    def securities
      @mutex.synchronize do
        @securities
      end
    end

    def securities=(securities)
      @mutex.synchronize do
        @securities = securities
      end
    end

    private

    def retrieve_pairs
      securities ? securities.list_pairs : []
    end

    def retrieve_tick
      if securities
        convert_rates(securities.list_rates, time_source.now)
      else
        Jiji::Model::Trading::NilTick.new
      end
    end

    def order(pair_id, type, count)
      check_setting_finished
      position = securities.order(pair_id, type, count)
      position.position_id
    end

    def do_close(position)
      check_setting_finished
      securities.commit(position.external_position_id, position.lot)
    end

    def check_setting_finished
      fail Jiji::Errors::NotInitializedException unless securities
    end

    def convert_rates(rate, timestamp)
      values = rate.each_with_object({}) do |p, r|
        r[p[0]] = convert_rate_to_tick(p[1])
        r
      end
      Tick.create(values, timestamp)
    end

    def convert_rate_to_tick(r)
      Tick::Value.new(r.bid, r.ask, r.buy_swap, r.sell_swap)
    end

  end
end
