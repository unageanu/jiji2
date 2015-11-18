# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  # レート情報
  class Tick

    include Enumerable
    include Jiji::Utils::ValueObject
    include Jiji::Errors

    # 通貨ペアをキーとする Tick::Value のハッシュ
    attr_reader :values
    # 日時
    attr_reader :timestamp

    def initialize(values, timestamp) #:nodoc:
      @values    = values
      @timestamp = timestamp
    end

    # 通貨ペアに対応する Tick::Value を取得します
    #
    # pair_name:: 通貨ペア名
    # 戻り値:: Tick::Value
    def [](pair_name)
      values[pair_name]
    end

    # レートを列挙します
    def each(&block)
      values.each(&block)
    end

    # レートの要素数を取得します
    # 戻り値:: レートの要素数
    def length
      values.length
    end

    def +(other) #:nodoc:
      illegal_argument unless timestamp == other.timestamp
      Tick.new(other.values.merge(values), timestamp)
    end

    def self.merge(a, b) #:nodoc:
      hash = a.each_with_object({}) { |tick, r| r[tick.timestamp.to_i] = tick }
      b.each do |tick|
        key = tick.timestamp.to_i
        hash[key] = hash[key] ? hash[key] + tick : tick
      end
      hash.values.sort_by { |tick| tick.timestamp }
    end

    class Value

      include Jiji::Utils::ValueObject
      include Jiji::Web::Transport::Transportable

      # bidレート
      attr_reader :bid
      # askレート
      attr_reader :ask

      def initialize(bid = 0, ask = 0) #:nodoc:
        @bid = bid
        @ask = ask
      end

    end

  end
end
