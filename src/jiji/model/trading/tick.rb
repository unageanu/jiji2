# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  class Tick

    include Enumerable
    include Mongoid::Document

    store_in collection: 'ticks'

    field :values,    type: Hash
    field :timestamp, type: Time

    attr_accessor :swaps

    index({ timestamp: 1 }, name: 'ticks_timestamp_index')

    attr_readonly :values, :timestamp

    def self.create(pair_and_values, timestamp)
      timestamp = timestamp.round
      Tick.new do |t|
        t.values    = create_values(pair_and_values)
        t.swaps     = create_swaps(pair_and_values, timestamp)
        t.timestamp = timestamp
      end
    end

    def [](pair_name)
      pair = Pairs.instance.create_or_get(pair_name)
      create_value(pair)
    end

    def each(&block)
      values.each do |k, _v|
        pair = Pairs.instance.get_by_id(k.to_i)
        block.call([pair.name, self[pair.name]]) unless pair.nil?
      end
    end

    def self.create_from_hash(pair, hash, swaps)
      swap = swaps.get_swap_at(pair.pair_id, hash['timestamp'])
      Tick::Value.new(hash['bid'], hash['ask'], swap.buy_swap, swap.sell_swap)
    end

    class Value

      include Jiji::Utils::ValueObject
      include Jiji::Web::Transport::Transportable

      attr_reader :bid, :ask, :buy_swap, :sell_swap

      def initialize(bid = 0, ask = 0, buy_swap = 0, sell_swap = 0)
        @bid = bid
        @ask = ask
        @sell_swap = sell_swap
        @buy_swap = buy_swap
      end

      def values
        [bid, ask, buy_swap, sell_swap]
      end

      def to_h
        {
          bid: bid,
          ask: ask,
          buy_swap: buy_swap,
          sell_swap: sell_swap
        }
      end

    end

    private

    def self.create_values(pair_and_values)
      pair_and_values.each_with_object({}) do |v, r|
        pair = Pairs.instance.create_or_get(v[0])
        r[pair.pair_id.to_s] = [v[1].bid, v[1].ask]
      end
    end

    def create_value(pair)
      check_values_includes_pair(pair)
      v    = values[pair.pair_id.to_s]
      swap = @swaps[pair.pair_id]
      Value.new(v[0], v[1], swap.buy_swap, swap.sell_swap)
    end

    def check_values_includes_pair(pair)
      if pair.nil? || !values.include?(pair.pair_id.to_s)
        fail ArgumentError, "illegal pair. pair=#{pair}"
      end
    end

    def self.create_swaps(pair_and_values, timestamp)
      pair_and_values.each_with_object({}) do |v, r|
        pair = Pairs.instance.create_or_get(v[0])
        r[pair.pair_id] = create_swap(pair, v[1], timestamp)
      end
    end

    def self.create_swap(pair, value, timestamp)
      Internal::Swap.new do |s|
        s.pair_id   = pair.pair_id
        s.buy_swap  = value.buy_swap
        s.sell_swap = value.sell_swap
        s.timestamp = timestamp
      end
    end

  end

  class NilTick

    include Enumerable

    attr_reader :timestamp

    def initialize(timestamp = Time.now)
      @timestamp = timestamp
    end

    def [](_pair_name)
      nil
    end

    def each(&_block)
    end

    def save
    end

  end
end
