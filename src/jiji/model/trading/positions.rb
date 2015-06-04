# coding: utf-8
require 'forwardable'

module Jiji::Model::Trading
  class Positions

    include Enumerable
    extend Forwardable

    def_delegators :@map, :[], :include?
    def_delegators :@positions, :each, :length, :size

    def initialize( positions, position_builder )
      @position_builder =  position_builder

      @positions = positions
      @map = to_map(positions)
    end

    def update( new_positions )
      @positions = new_positions.map do |p|
        sync_or_save_position(@map.delete( p.internal_id ), p)
      end
      mark_as_closed(@map.values)
      @map = to_map(@positions)
    end

    def update_price( tick )
      @positions.each do |p|
        p.update(tick)
      end
    end

    def apply_order_result(result, tick)
      add(result.trade_opened, tick) if result.trade_opened
      split(result.trade_reduced) if result.trade_reduced
      result.trades_closed.each do |close_result|
        apply_close_result(close_result)
      end
    end

    def apply_close_result(result)
      return unless @map.include?(result.internal_id)
      position = @map[result.internal_id]
      position.close(result.price, result.timestamp)
    end

    private

    def sync_or_save_position(original, new_position)
      if original
        unless are_equals?( original, new_position )
          sync_position( original, new_position )
        end
        return original
      else
        new_position.save
        return new_position
      end
    end

    def are_equals?( position, new_position )
      position.pair_name      == new_position.pair_name \
      && position.units          == new_position.units \
      && position.sell_or_buy    == new_position.sell_or_buy \
      && position.entry_price    == new_position.entry_price \
      && position.entered_at     == new_position.entered_at \
      && position.closing_policy == new_position.closing_policy
    end

    def sync_position( position, new_position )
      position.pair_name      = new_position.pair_name
      position.units          = new_position.units
      position.sell_or_buy    = new_position.sell_or_buy
      position.entry_price    = new_position.entry_price
      position.entered_at     = new_position.entered_at
      position.closing_policy = new_position.closing_policy
      position.save
    end

    def mark_as_closed(positions)
      positions.each do |p| p.close end
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
    end

    def to_map(positions)
      positions.each_with_object({}) do |p, r|
        r[p.internal_id] = p
      end
    end

  end
end
