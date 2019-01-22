# frozen_string_literal: true

module Jiji::Model::Agents
  module Context
    def self.new_context
      m = Module.new
      m.extend(Context)
      m
    end

    def self._delegates
      Delegate.instance.delegates
    end

    def self._delegates=(delegates)
      Delegate.instance.delegates = delegates
    end

    def const_missing(id)
      target = Delegate.instance.delegates.values.find do |v|
        v&.const_defined?(id)
      end
      target ? target.const_get(id) : super
    end

    def method_missing(name, *args, &block)
      target = Delegate.instance.delegates.values.find do |v|
        v&.respond_to?(name)
      end
      target ? target.send(name, *args, &block) : super
    end

    def respond_to_missing?(symbol, include_private)
      return false if Thread.current['__prevent__respond_to_missing']

      begin
        Thread.current['__prevent__respond_to_missing'] = true
        Delegate.instance.delegates.values.any? do |v|
          v&.respond_to?(symbol, include_private)
        end
      ensure
        Thread.current['__prevent__respond_to_missing'] = false
      end
    end
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
