# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'

module Jiji
module Model
module Trading

  class Position
  
    include Mongoid::Document
    include Jiji::Errors
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    
    store_in collection: "positions"
    
    field :back_test_id,          type: BSON::ObjectId # RMTの場合nil
    field :external_position_id,  type: String # 接続先証券会社でpositionを識別するためのID。バックテストの場合nil
    
    field :pair_id,       type: Integer
    field :lot,           type: Integer
    field :trading_unit,  type: Integer
    field :sell_or_buy,   type: Symbol
    field :status,        type: Symbol
    
    field :entry_price,   type: Float
    field :current_price, type: Float
    field :exit_price,    type: Float
    
    field :entered_at,    type: Time
    field :exited_at,     type: Time
    field :updated_at,    type: Time
    
    index(
      { :back_test_id => 1, :entered_at =>1 }, 
      { :name => "positions_back_test_id_entered_at_index" })
    
    attr_readonly :back_test_id, :external_position_id, :pair_id
    attr_readonly :lot, :sell_or_buy, :entry_price, :entered_at
    attr_readonly :trading_unit
    
    def to_h
      {
        :back_test_id         => back_test_id, 
        :external_position_id => external_position_id,
        :pair_id              => pair_id,
        :lot                  => lot,
        :trading_unit         => trading_unit,
        :sell_or_buy          => sell_or_buy,
        :entry_price          => entry_price,
        :current_price        => current_price,
        :exit_price           => exit_price,
        :entered_at           => entered_at,
        :exited_at            => exited_at,
        :updated_at           => updated_at,
        :status               => status
      }
    end
    
    def self.create( back_test_id, external_position_id, 
        pair_id, lot, trading_unit, sell_or_buy, tick ) 
      position = Position.new {|p|
        p.back_test_id         = back_test_id
        p.pair_id              = pair_id
        p.lot                  = lot
        p.trading_unit         = trading_unit
        p.sell_or_buy          = sell_or_buy
        p.entry_price          = calculate_entry_price( tick, pair_id, sell_or_buy )
        p.entered_at           = tick.timestamp
        p.current_price        = calculate_current_price( tick, pair_id, sell_or_buy )
        p.updated_at           = p.entered_at
        p.status               = :live
        p.external_position_id = external_position_id
      }
      position.save
      position
    end
    
    def profit_or_loss
      (current_price * lot * trading_unit - entry_price * lot * trading_unit) \
        * (sell_or_buy == :buy ? 1 : -1)
    end
    
    def close
      self.exit_price = current_price
      self.status     = :closed
      self.exited_at  = updated_at
      self.save
    end
    
    def update( tick )
      self.current_price = Position.calculate_current_price( tick, pair_id, sell_or_buy )
      self.updated_at    = tick.timestamp 
    end
    
  private 
    def self.calculate_entry_price( tick, pair_id, sell_or_buy )
      # 新規エントリー時は、:buy の場合買値で買い、:sell の場合売値で売る。
      self.calculate_price(tick, pair_id, sell_or_buy)
    end
    def self.calculate_current_price( tick, pair_id, sell_or_buy )
      # 現在価格は、:buy の場合売値、:sell の場合買値で計算。
      self.calculate_price(tick, pair_id, 
        sell_or_buy == :buy ? :sell : :buy)
    end
    def self.calculate_price( tick, pair_id, sell_or_buy )
      pair = Pairs.instance.get_by_id(pair_id) 
      value = tick[pair.name]
      sell_or_buy == :buy ? value.ask : value.bid
    end
    
  end

end
end
end
