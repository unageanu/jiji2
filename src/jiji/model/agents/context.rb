# coding: utf-8

module Jiji::Model::Agents
  module Context
    def self.new_context
      m = Module.new
      define_const_missing(m)
      define_method_missing(m)
      m
    end

    def self._delegates
      Delegate.instance.delegates
    end
    def self._delegates=(delegates)
      Delegate.instance.delegates = delegates
    end

    private

    def self.define_const_missing(m)
      def m.const_missing(id)
        result = nil
        Delegate.instance.delegates.each_pair do |_k, v|
          if v.const_defined?(id)
            result = v.const_get(id)
            break
          end
        end
        result ? result : super
      end
    end
    def self.define_method_missing(m)
      def m.method_missing(name, *args, &block)
        target = nil
        Delegate.instance.delegates.each_pair do |_k, v|
          if v.respond_to?(name)
            target = v
            break
          end
        end
        target ? target.send(name, *args, &block) : super
      end
    end

    define_const_missing(self)
    define_method_missing(self)
  end

  class Delegate

    include Singleton

    def initialize
      @delegates = {}
    end

    attr_reader :delegates

    def delegates=(delegates)
      @delegates = delegates || {}
    end

  end
end
