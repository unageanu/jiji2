# coding: utf-8

require 'thread'
require 'observer'

module Jiji::Model::Securities
  class SecuritiesProvider

    include Observable

    def initialize
      @mutex = Mutex.new
      set(NilSecurities.new)
    end

    def get
      @mutex.synchronize do
        @securities
      end
    end

    def set(securities)
      @mutex.synchronize do
        @securities = securities
      end
      changed
      notify_observers(name: :property_changed, value: securities)
    end

  end
end
