# frozen_string_literal: true

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  # 通貨ペア
  class Pair

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # 通貨ペア名 例) :EURJPY
    attr_reader :name
    # 内部ID
    attr_reader :internal_id
    # 1 pipの値。
    attr_reader :pip
    # 最大取引単位
    attr_reader :max_trade_units
    # 通貨ペアの小数点精度
    attr_reader :precision
    # 必要証拠金率
    attr_reader :margin_rate

    def initialize(name, internal_id, pip,
      max_trade_units, precision, margin_rate) #:nodoc:
      @name            = name
      @internal_id     = internal_id
      @pip             = pip
      @max_trade_units = max_trade_units
      @precision       = precision
      @margin_rate     = margin_rate
    end

  end

  class Pairs #:nodoc:

    include Encase
    include Jiji::Errors

    needs :securities_provider

    def initialize
      @lock = Mutex.new
    end

    def on_inject
      securities_provider.add_observer self
    end

    def update(ev)
      reload
    end

    def get_by_name(name)
      @lock.synchronize do
        load_if_required
        @by_name[name] || not_found('pair', name: name)
      end
    end

    def all
      @lock.synchronize do
        load_if_required
        @by_name.values.sort_by(&:name)
      end
    end

    def reload
      @lock.synchronize do
        load
      end
    end

    private

    def load_if_required
      load unless @by_name
    end

    def load
      securities = securities_provider.get
      @by_name = securities.retrieve_pairs.each_with_object({}) do |pair, r|
        r[pair.name] = pair
      end
    end

  end
end
