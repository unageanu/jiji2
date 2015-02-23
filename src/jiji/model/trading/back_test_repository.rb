# coding: utf-8

require 'encase'
require 'thread/pool'

module Jiji::Model::Trading
  class BackTestRepository
    include Encase
    include Jiji::Errors

    attr_accessor :container

    def initialize
      @back_tests = {}
    end

    def on_inject
      load
    end

    def all
      @back_tests.values
    end

    def register(config)
      back_test = BackTest.create_from_hash(config)
      setup_back_test(back_test)
      back_test.save

      @back_tests[back_test.id] = back_test
      back_test
    end

    def get(id)
      @back_tests[id] || not_found(id)
    end

    def delete(id)
      back_test = get(id)
      back_test.process.stop

      back_test.delete
      @back_tests.delete(id)
    end

    def stop
      all.each { |t| t.process.stop }
    end

    private

    def load
      @back_tests = BackTest
                    .order_by(:created_at.asc)
                    .all.each_with_object(@back_tests) do|t, r|
        setup_back_test(t)
        r[t.id] = t
        r
      end
    end

    def setup_back_test(back_test)
      container.inject(back_test)
      back_test.setup
      back_test
    end
  end
end
