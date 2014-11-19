# coding: utf-8

require 'jiji/utils/value_object'

module Jiji
module Model
module Trading

  class BidAsk
    
    include Jiji::Utils::ValueObject
    
    def initialize( base, buy_spread, sell_spread )
      @bid = base + buy_spread 
      @ask = base + sell_spread 
    end
    
    attr_reader :bid, :ask
    
  protected
    def values
      [bid, ask]
    end

  end

end
end
end