# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  class Rate

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    attr_reader :pair, :open, :close, :high, :low
    attr_reader :timestamp, :close_timestamp

    def initialize(pair, timestamp, open, close = open,
      high = open, low = open, close_timestamp = timestamp)
      @pair            = pair
      @open            = open
      @close           = close
      @high            = high
      @low             = low
      @timestamp       = timestamp
      @close_timestamp = close_timestamp
    end

    def buy_swap
      @open.buy_swap
    end

    def sell_swap
      @open.sell_swap
    end

    def self.create_from_tick(pair_name, *ticks)
      pair = Pairs.instance.create_or_get(pair_name)
      rate = Rate.new(pair, ticks[0].timestamp, ticks[0][pair_name])
      ticks.each_with_object(rate) do |n, r|
        r << n
      end
    end

    def self.union(*rates)
      rates.inject(rates.pop) { |a, e| a + e }
    end

    def to_h
      {
        pair: pair,
        open: open,
        close: close,
        high: high,
        low: low,
        timestamp: timestamp
      }
    end

    def <<(tick)
      value = tick[pair.name]
      update_open(value, tick.timestamp)
      update_close(value, tick.timestamp)
      update_high(value)
      update_low(value)
    end

    def +(other)
      update_open(other.open, other.timestamp)
      update_close(other.close, other.close_timestamp)
      update_high(other.high)
      update_low(other.low)
      self
    end

    protected

    def values
      [pair, open, close, high, low, timestamp]
    end

    private

    def update_open(value, timestamp)
      return unless timestamp < @timestamp
      @open      = value
      @timestamp = timestamp
    end

    def update_close(value, timestamp)
      return unless timestamp > @close_timestamp
      @close           = value
      @close_timestamp = timestamp
    end

    def update_high(value)
      return unless @high.bid  < value.bid
      @high  = value
    end

    def update_low(value)
      return unless  @low.bid > value.bid
      @low  = value
    end

  end
end
