# coding: utf-8

require 'thread'

module Jiji::Model::Securities

  class SecuritiesProvider

    def initialize
      @mutex = Mutex.new
      set( NilSecurities.new )
    end

    def get
      @mutex.synchronize do
        @securities
      end
    end

    def set=(securities)
      @mutex.synchronize do
        @securities = securities
      end
    end

  end

end
