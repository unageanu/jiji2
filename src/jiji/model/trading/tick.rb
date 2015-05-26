# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading

  class Tick

    include Enumerable
    include Jiji::Utils::ValueObject
    include Jiji::Errors

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

    def +(other)
      illegal_argument unless self.timestamp == other.timestamp
      Tick.new( other.values.merge(self.values), timestamp )
    end

    def self.merge(a, b)
      hash = a.each_with_object({}) {|tick,r| r[tick.timestamp.to_i] = tick }
      b.each do |tick|
        key = tick.timestamp.to_i
        hash[key] = hash[key] ? hash[key] + tick : tick
      end
      hash.values.sort_by {|tick| tick.timestamp}
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
