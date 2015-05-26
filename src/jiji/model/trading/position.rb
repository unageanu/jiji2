# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'

module Jiji::Model::Trading
  class Position

    include Mongoid::Document
    include Jiji::Errors
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Utils

    store_in collection: 'positions'

    field :back_test_id,          type: BSON::ObjectId # RMTの場合nil
    field :external_position_id,  type: String
    # 接続先証券会社でpositionを識別するためのID。バックテストの場合nil

    field :pair_name,     type: Symbol
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
      { back_test_id: 1, entered_at: 1 },
      name: 'positions_back_test_id_entered_at_index')

    attr_readonly :back_test_id, :external_position_id, :pair_name
    attr_readonly :lot, :sell_or_buy, :entry_price, :entered_at
    attr_readonly :trading_unit

    def to_h
      h = {}
      insert_trading_information_to_hash(h)
      insert_price_and_time_information_to_hash(h)
      h
    end

    def self.create(back_test_id, external_position_id,
        pair_name, lot, trading_unit, sell_or_buy, tick)
      position = Position.new do |p|
        p.initialize_trading_information(back_test_id,
          external_position_id, pair_name, lot, trading_unit, sell_or_buy)
        p.initialize_price_and_time(tick, pair_name, sell_or_buy)
      end
      position.save
      position
    end

    def profit_or_loss
      current = actual_amount_of(current_price)
      entry   = actual_amount_of(entry_price)
      (current - entry) * (sell_or_buy == :buy ? 1 : -1)
    end

    def close
      return if status == :closed
      self.exit_price = current_price
      self.status     = :closed
      self.exited_at  = updated_at
      save
    end

    def update(tick)
      return if status == :closed
      self.current_price = PricingUtils.calculate_current_price(
        tick, pair_name, sell_or_buy)
      self.updated_at    = tick.timestamp
    end

    def initialize_price_and_time(tick, pair_name, sell_or_buy)
      self.entry_price   = PricingUtils.calculate_entry_price(
        tick, pair_name, sell_or_buy)
      self.current_price = PricingUtils.calculate_current_price(
        tick, pair_name, sell_or_buy)
      self.entered_at    = tick.timestamp
      self.updated_at    = tick.timestamp
    end

    def initialize_trading_information(back_test_id,
        external_position_id, pair_name, lot, trading_unit, sell_or_buy)
      self.back_test_id         = back_test_id
      self.pair_name            = pair_name
      self.lot                  = lot
      self.trading_unit         = trading_unit
      self.sell_or_buy          = sell_or_buy
      self.status               = :live
      self.external_position_id = external_position_id
    end

    private

    def actual_amount_of(price)
      BigDecimal.new(price, 10) * lot * trading_unit
    end

    def insert_trading_information_to_hash(h)
      h[:back_test_id]         = back_test_id
      h[:external_position_id] = external_position_id
      h[:pair_name]            = pair_name
      h[:lot]                  = lot
      h[:trading_unit]         = trading_unit
      h[:sell_or_buy]          = sell_or_buy
      h[:status]               = status
    end

    def insert_price_and_time_information_to_hash(h)
      h[:entry_price]   = entry_price
      h[:current_price] = current_price
      h[:exit_price]    = exit_price
      h[:entered_at]    = entered_at
      h[:exited_at]     = exited_at
      h[:updated_at]    = updated_at
    end

  end
end
