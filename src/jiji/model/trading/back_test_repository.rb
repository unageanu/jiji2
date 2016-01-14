# coding: utf-8

require 'encase'
require 'thread/pool'

module Jiji::Model::Trading
  class BackTestRepository

    include Encase
    include Jiji::Errors

    needs :backtest_thread_pool

    attr_accessor :container

    def initialize
      @backtests = {}
    end

    def all
      @backtests.values
    end

    def runnings
      @backtests.values.reject do |b|
        b.retrieve_process_status != :running
      end
    end

    def collect_backtests_by_id(ids)
      tests = ids.map do |id|
        begin
          get(id)
        rescue Jiji::Errors::NotFoundException
          # ignore
          nil
        end
      end
      tests.reject { |test| test.nil? }
    end

    def register(config)
      config = config.with_indifferent_access
      backtest = BackTest.create_from_hash(config)
      setup_backtest(backtest)
      backtest.save
      backtest.create_agent_instances(extract_agent_setting(config), true)

      @backtests[backtest.id] = backtest
      backtest.start
      backtest
    end

    def get(id)
      @backtests[id] || not_found(id)
    end

    def restart(id)
      backtest = get(id)
      unless backtest.status != :running || backtest.trading_context.finished?
        illegal_state
      end
      config = extract_backtest_config(id)
      new_test = register(config)
      delete(id)
      new_test
    end

    def delete(id)
      backtest = get(id)
      backtest.pause
      backtest.destroy
      @backtests.delete(id)
    end

    def stop
      rest = all.reject do |t|
        if t.retrieve_process_status == :wait_for_start
          t.pause
          true
        else
          false
        end
      end
      rest.each { |t| t.pause }
      backtest_thread_pool.shutdown
    end

    def load
      @backtests = BackTest
                   .order_by(:created_at.asc)
                   .all.each_with_object(@backtests) do |t, r|
        setup_backtest(t)
        t.start if t.start_on_startup?
        r[t.id] = t
        r
      end
    end

    private

    def extract_agent_setting(config)
      setting = config[:agent_setting] || {}
      illegal_argument if setting.empty?
      setting
    end

    def extract_backtest_config(id)
      backtest = get(id)
      backtest.to_h.merge({
        agent_setting: backtest.agent_settings.map do |s|
          hash = s.to_h
          hash.delete :id
          hash[:agent_name] = hash[:name]
          hash
        end
      })
    end

    def setup_backtest(backtest)
      container.inject(backtest)
      backtest.setup
      backtest
    end

  end
end
