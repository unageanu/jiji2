require 'jiji/configurations/mongoid_configuration'

module Jiji
module Model
module Dao

  class Rate
    include Mongoid::Document
    store_in collection: "rates"
    
    field :pair, type: Integer
    field :open, type: Integer
    field :close, type: Integer
    field :high, type: Integer
    field :low, type: Integer
    field :timestamp, type: DateTime
    
    def clone
      r = Jiji::Rate.new
      r.pair      = self.pair
      r.open      = self.open
      r.close     = self.close
      r.high      = self.high
      r.low       = self.low
      r.timestamp = self.timestamp
      return r
    end
    
    def self.union( *others )
      rate = others[0].clone
      others.each {|r|
        if r.timestamp < rate.timestamp
          rate.open = r.open 
          rate.timestamp = r.timestamp
        else
          rate.close = r.close 
        end
        rate.high = Math.max(rate.high, r.high)
        rate.low  = Math.min(rate.low,  r.low)
      }
    end
  end

end
end
end
