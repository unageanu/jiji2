# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/model/trading/bid_ask'

module Jiji
module Model
module Trading

  class Rate
  
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    store_in collection: "rates"
    
    field :pair_id,  type: Integer
    
    field :open_price,     type: Float
    field :close_price,    type: Float
    field :high_price,     type: Float
    field :low_price,      type: Float
    
    field  :sell_swap, type: Integer
    field  :buy_swap,  type: Integer
    
    field :timestamp, type: DateTime
    
    attr_accessor :pair
    
    def open
      bid_ask( open_price )
    end
    def close
      bid_ask( close_price )
    end
    def high
      bid_ask( high_price )
    end
    def low
      bid_ask( low_price )
    end

    attr_writer :bid_spread, :ask_spread
    
    def bid_spread
      @bid_spread || 0
    end
    def ask_spread
      @ask_spread || 0
    end
    
    def self.union( *others )
      rate = others[0].clone
      others.each {|r|
        if r.timestamp < rate.timestamp
          rate.open_price = r.open_price 
          rate.timestamp = r.timestamp
        else
          rate.close_price = r.close_price 
        end
        rate.high_price = Math.max(rate.high_price, r.high_price)
        rate.low_price  = Math.min(rate.low_price,  r.low_price)
      }
    end

  protected
    def values
      [pair_id, buy_swap, sell_swap, timestamp,
        open_price, close_price, high_price, low_price]
    end
  
  private
    def bid_ask( price )
      BidAsk.new( price, bid_spread, ask_spread )
    end
  
  end 

end
end
end
