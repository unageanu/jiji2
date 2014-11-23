# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'

module Jiji
module Model
module Trading

  class Tick
    
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    field :pair_id,  type: Integer
    
    field :bid,       type: Float
    field :ask,       type: Float
    field :sell_swap, type: Integer
    field :buy_swap,  type: Integer
    
    field :timestamp, type: DateTime
    
  protected
    def values
      [pair_id, bid, ask, sell_swap, buy_swap, timestamp]
    end

  end

end
end
end