# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  class Pair

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    attr_reader :name, :internal_id, :pip, :max_trade_units

    def initialize(name, internal_id, pip, max_trade_units)
      @name            = name
      @internal_id     = internal_id
      @pip             = pip
      @max_trade_units = max_trade_units
    end

  end

  class Pairs

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
      @by_name = securities.retrieve_pairs.each_with_object({}) do|pair, r|
        r[pair.name] = pair
      end
    end

  end
end
