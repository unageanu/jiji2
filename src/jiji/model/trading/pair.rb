# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  class Pair

    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    store_in collection: 'pairs'

    field :pair_id,       type: Integer
    field :name,          type: Symbol

    index({ pair_id: 1 }, unique: true, name: 'pairs_pair_id_index')
    index({ name: 1 }, unique: true, name: 'pairs_name_index')

    def to_h
      { pair_id: pair_id, name: name }
    end

    attr_readonly :pair_id, :name

  end

  class Pairs

    include Singleton
    include Jiji::Errors

    def initialize
      @lock = Mutex.new
      load
    end

    def register(name)
      name = name.to_sym
      @lock.synchronize do
        unless @by_name.include?(name)
          pair = register_new_pair(name)
          @by_name[name]       = pair
          @by_id[pair.pair_id.to_s] = pair
        end
        @by_name[name]
      end
    end

    def create_or_get(name)
      register(name)
    end

    def get_by_id(id)
      @lock.synchronize do
        @by_id[id.to_s] || not_found('pair', id: id)
      end
    end

    def get_by_name(name)
      @lock.synchronize do
        @by_name[name] || not_found('pair', name: name)
      end
    end

    def all
      @lock.synchronize do
        @by_id.values.sort_by(&:id)
      end
    end

    def reload
      load
    end

    private

    def load
      @by_name = {}
      @by_id   = {}
      Pair.each do |pair|
        @by_name[pair.name]  = pair
        @by_id[pair.pair_id.to_s] = pair
      end
    end

    def register_new_pair(name)
      pair = Pair.new do |p|
        p.name    = name
        p.pair_id = new_id
      end
      pair.save
      pair
    end

    def new_id
      max = @by_name.values.max_by(&:pair_id)
      max ? max.pair_id + 1 : 0
    end

  end
end
