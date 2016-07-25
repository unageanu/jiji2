# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading

  # 四本値。
  # open, close, high, low の各値は Tick::Value 型になります。
  class Rate

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # 通貨ペア 例) :USDJPY
    attr_reader :pair
    # 始値
    attr_reader :open
    # 終値
    attr_reader :close
    # 高値
    attr_reader :high
    # 安値
    attr_reader :low
    # 日時
    attr_reader :timestamp
    # 出来高
    attr_reader :volume

    attr_reader :close_timestamp #:nodoc:

    def initialize(pair, timestamp, open, close = open,
      high = open, low = open, volume = 0, close_timestamp = timestamp) #:nodoc:
      @pair            = pair
      @open            = open
      @close           = close
      @high            = high
      @low             = low
      @volume          = volume
      @timestamp       = timestamp
      @close_timestamp = close_timestamp
    end

    def self.create_from_tick(pair_name, *ticks) #:nodoc:
      rate = Rate.new(pair_name, ticks[0].timestamp, ticks[0][pair_name])
      ticks.each_with_object(rate) do |n, r|
        r << n
      end
    end

    def self.union(*rates) #:nodoc:
      rates.inject(rates.pop) { |a, e| a + e }
    end

    def to_h #:nodoc:
      {
        pair:      pair,
        open:      open,
        close:     close,
        high:      high,
        low:       low,
        volume:    volume,
        timestamp: timestamp
      }
    end

    def <<(tick) #:nodoc:
      value = tick[pair]
      update_open(value, tick.timestamp)
      update_close(value, tick.timestamp)
      update_high(value)
      update_low(value)
    end

    def +(other) #:nodoc:
      update_open(other.open, other.timestamp)
      update_close(other.close, other.close_timestamp)
      update_high(other.high)
      update_low(other.low)
      self
    end

    protected

    def values #:nodoc:
      [pair, open, close, high, low, volume, timestamp]
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
      return unless @high.bid < value.bid
      @high = value
    end

    def update_low(value)
      return unless @low.bid > value.bid
      @low = value
    end

  end
end
