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

    field :backtest_id,   type: BSON::ObjectId # RMTの場合nil
    field :internal_id,    type: String

    field :pair_name,      type: Symbol
    field :units,          type: Integer
    field :sell_or_buy,    type: Symbol
    field :status,         type: Symbol

    field :entry_price,    type: Float
    field :current_price,  type: Float
    field :exit_price,     type: Float

    field :entered_at,     type: Time
    field :exited_at,      type: Time
    field :updated_at,     type: Time

    embeds_one :closing_policy

    index(
      { backtest_id: 1, entered_at: 1 },
      name: 'positions_backtest_id_entered_at_index')

    attr_readonly :internal_id

    def attach_broker(broker)
      @broker = broker
    end

    def to_h
      h = {}
      insert_trading_information_to_hash(h)
      insert_price_and_time_information_to_hash(h)
      h[:closing_policy] = closing_policy.to_h
      h
    end

    def profit_or_loss
      current = actual_amount_of(current_price)
      entry   = actual_amount_of(entry_price)
      (current - entry) * (sell_or_buy == :buy ? 1 : -1)
    end

    def modify
      @broker.modify_position(self) if @broker
    end

    def close
      illegal_state unless @broker
      @broker.close_position(self)
    end

    # for internal use.
    def update_state_for_reduce(units, time)
      return if status == :closed
      self.units = self.units - units
      self.updated_at = time
    end

    # for internal use.
    def update_state_to_closed(price = current_price, time = updated_at)
      return if status == :closed
      self.exit_price    = price
      self.current_price = price
      self.status        = :closed
      self.exited_at     = time
      self.updated_at    = time
    end

    # for internal use.
    def update_price(tick)
      return if status == :closed
      self.current_price = PricingUtils.calculate_current_price(
        tick, pair_name, sell_or_buy)
      self.updated_at    = tick.timestamp
    end

    private

    def actual_amount_of(price)
      BigDecimal.new(price, 10) * units
    end

    def insert_trading_information_to_hash(h)
      h[:backtest_id]         = backtest_id
      h[:internal_id]          = internal_id
      h[:pair_name]            = pair_name
      h[:units]                = units
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
