# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading

  class Tick

    include Enumerable
    include Jiji::Utils::ValueObject

    attr_reader :values, :timestamp

    def initialize(values, timestamp)
      @values    = values
      @timestamp = timestamp
    end

    def [](pair_name)
      values[pair_name]
    end

    def each(&block)
      values.each(&block)
    end

    def length
      values.length
    end

    class Value

      include Jiji::Utils::ValueObject
      include Jiji::Web::Transport::Transportable

      attr_reader :bid, :ask

      def initialize(bid = 0, ask = 0)
        @bid = bid
        @ask = ask
      end

    end

  end

end
