# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'
require 'jiji/web/transport/transportable'
require 'protected_attributes'

module Jiji
module Model
module Trading

  class Position
  
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    
    store_in collection: "positions"
    
    field :back_test_id,          type: String # RMTの場合nil
    field :external_position_id,  type: String # 接続先証券会社でpositionを識別するためのID。バックテストの場合nil
    
    field :pair_id,       type: Integer
    field :count,         type: Integer
    field :sell_or_buy,   type: Symbol
    field :status,        type: Symbol
    
    field :entry_price,   type: Float
    field :exit_price,    type: Float
    
    field :entered_at,    type: Time
    field :exited_at,     type: Time
    
    index(
      { :back_test_id => 1, :entered_at =>1 }, 
      { :name => "positions_back_test_id_entered_at_index" })
    
    attr_readonly :back_test_id, :external_position_id, :pair_id
    attr_readonly :count, :sell_or_buy, :entry_price, :entered_at
    
    def to_h
      {
        :back_test_id         => back_test_id, 
        :external_position_id => external_position_id,
        :pair_id              => pair_id,
        :count                => count,
        :sell_or_buy          => sell_or_buy,
        :entry_price          => entry_price,
        :exit_price           => exit_price,
        :entered_at           => entered_at,
        :exited_at            => exited_at,
        :status               => status
      }
    end
    
    def create( back_test_id, external_position_id, 
        pair_id, count, buy_or_sel, entry_price, entered_at ) 
      position = Position.new {|p|
        p.back_test_id         = back_test_id
        p.pair_id              = pair_id
        p.count                = count
        p.sell_or_buy          = sell_or_buy
        p.entry_price          = entry_price
        p.entered_at           = entered_at
        p.status               = :live
        p.external_position_id = external_position_id
      }
      position.save
      position
    end
    
    def profit_or_loss
      (@current_price * count - entered_at * count) \
        * (sell_or_buy == :buy ? 1 : -1)
    end
    
    def close
      self.exit_price = @current_price
      self.status = :closed
      self.exited_at = @time_source.now
      self.save
    end
    
    def update
      pair = Pair.instance.create_or_get(@pair_id) 
      value = @broker.current_rates[pair.name]
      @current_price = sell_or_buy == :buy ? value.ask : value.bid
    end
    
  end

end
end
end
