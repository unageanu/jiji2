# coding: utf-8
require 'forwardable'

module Jiji::Model::Trading
  class Positions

    include Enumerable
    extend Forwardable

    def_delegators :@map, :[], :include?
    def_delegators :@positions, :each, :length, :size

    def initialize(positions, position_builder, account)
      @position_builder =  position_builder
      @account = account

      @positions = positions
      @map = to_map(positions)
    end

    # for internal use.
    def update(new_positions)
      @positions = new_positions.map do |p|
        sync_or_save_position(@map.delete(p.internal_id), p)
      end
      mark_as_closed(@map.values)
      @map = to_map(@positions)
      @account.update(self, @account.updated_at)
    end

    # for internal use.
    def update_price(tick, pairs)
      @positions.each do |p|
        pair = pairs.find { |pa| pa.name == p.pair_name }
        p.update_price(tick)
        p.closing_policy.update_price(p, pair)
        p.save
      end
      @account.update(self, tick.timestamp)
    end

    # for internal use.
    def apply_order_result(result, tick)
      add(result.trade_opened, tick) if result.trade_opened
      split(result.trade_reduced) if result.trade_reduced
      result.trades_closed.each do |close_result|
        apply_close_result(close_result)
      end
      @account.update(self, tick.timestamp)
    end

    # for internal use.
    def apply_close_result(result)
      return unless @map.include?(result.internal_id)
      position = @map[result.internal_id]
      position.update_state_to_closed(result.price, result.timestamp)
      position.save

      @account += position.profit_or_loss
      @account.update(self, result.timestamp)
    end

    private

    def sync_or_save_position(original, new_position)
      if original
        unless are_equals?(original, new_position)
          sync_position(original, new_position)
        end
        return original
      else
        new_position.save
        return new_position
      end
    end

    def are_equals?(position, new_position)
      SYNCHRONIZE_PROPERTIES.all? do |key|
        position.method(key).call == new_position.method(key).call
      end
    end

    def sync_position(position, new_position)
      SYNCHRONIZE_PROPERTIES.each do |key|
        position.method("#{key}=").call(new_position.method(key).call)
      end
      position.save
    end

    SYNCHRONIZE_PROPERTIES = [
      :pair_name, :units, :sell_or_buy,
      :entry_price, :entered_at, :closing_policy
    ]

    def mark_as_closed(positions)
      positions.each do |p|
        p.update_state_to_closed
        p.save

        @account += p.profit_or_loss
      end
    end

    def add(order, tick)
      position = @position_builder.build_from_order(order, tick)
      position.save
      @positions << position
      @map[position.internal_id] = position
    end

    def split(result)
      return unless @map.include?(result.internal_id)
      position = @map[result.internal_id]

      new_position = @position_builder.split_and_close(position,
        position.units - result.units, result.price, result.timestamp)
      position.save
      new_position.save

      @account += new_position.profit_or_loss
    end

    def to_map(positions)
      positions.each_with_object({}) do |p, r|
        r[p.internal_id] = p
      end
    end

  end
end
