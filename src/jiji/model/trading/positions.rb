# coding: utf-8
require 'forwardable'

module Jiji::Model::Trading
  # 建玉一覧
  #
  #  positions = broker.positions # Positions オブジェクトが返されます
  #  positions.length
  #  positions.find { |o| o.sell_or_buy == :sell } #売建玉の一覧を取得
  #
  class Positions

    include Enumerable
    extend Forwardable

    def_delegators :@map, :[], :include?
    def_delegators :@positions, :each, :length, :size

    attr_accessor :account #:nodoc:

    def initialize(positions, position_builder, account) # :nodoc:
      @position_builder = position_builder
      @account = account

      @positions = positions
      @map = to_map(positions)
    end

    # for internal use.
    def update(new_positions) # :nodoc:
      @positions = new_positions.map do |p|
        sync_or_save_position(@map.delete(p.internal_id), p)
      end
      mark_as_closed(@map.values)
      @map = to_map(@positions)
      @account.update(self, @account.updated_at)
    end

    # for internal use.
    def update_price(tick, pairs) # :nodoc:
      @positions.each do |p|
        pair = pairs.find { |pa| pa.name == p.pair_name }
        p.update_price(tick, account.account_currency)
        p.closing_policy.update_price(p, pair)
        p.save
      end
      @account.update(self, tick.timestamp)
    end

    # for internal use.
    def apply_order_result(result, tick, agent = nil) # :nodoc:
      add(result.trade_opened, tick, agent) if result.trade_opened
      split(result.trade_reduced, agent) if result.trade_reduced
      result.trades_closed.each do |closed|
        close(closed.internal_id, closed.price, closed.timestamp, nil)
      end
      @account.update(self, tick.timestamp)
    end

    # for internal use.
    def apply_close_result(result) # :nodoc:
      close(result.internal_id, result.price,
        result.timestamp, result.profit_or_loss)
      @account.update(self, result.timestamp)
    end

    # for internal use.
    def replace(new_positions, account) # :nodoc:
      @account = account
      @positions.each do |p|
        p.update_state_to_lost
        p.save
      end
      new_positions.each { |p| p.save }
      @positions = new_positions
      @map = to_map(new_positions)
    end

    private

    def sync_or_save_position(original, new_position)
      if original
        unless PositionSynchronizer.are_equals?(original, new_position)
          PositionSynchronizer.sync_position(original, new_position)
        end
        return original
      else
        new_position.save
        return new_position
      end
    end

    def mark_as_closed(positions)
      positions.each do |p|
        p.update_state_to_closed
        p.save

        @account += p.profit_or_loss
      end
    end

    def add(order, tick, agent)
      position = @position_builder.build_from_order(order,
        tick, account.account_currency, agent)
      position.save
      @positions << position
      @map[position.internal_id] = position
    end

    def split(result, agent)
      return unless @map.include?(result.internal_id)
      position = @map[result.internal_id]

      new_position = @position_builder.split_and_close(position,
        position.units - result.units, result.price, result.timestamp, agent)
      position.save
      new_position.save

      @account += new_position.profit_or_loss
    end

    def close(internal_id, price, timestamp, profit)
      return unless @map.include?(internal_id)
      position = @map[internal_id]
      position.update_state_to_closed(price, timestamp, profit)
      position.save

      @positions = @positions.reject { |p| p.internal_id == internal_id }
      @map.delete(internal_id)
      @account += position.profit_or_loss
    end

    def to_map(positions)
      Jiji::Utils::Collections.to_map(positions) { |p| p.internal_id }
    end

    class PositionSynchronizer # :nodoc:

      def self.are_equals?(position, new_position)
        SYNCHRONIZE_PROPERTIES.all? do |key|
          position.method(key).call == new_position.method(key).call
        end
      end

      def self.sync_position(position, new_position)
        SYNCHRONIZE_PROPERTIES.each do |key|
          position.method("#{key}=").call(new_position.method(key).call)
        end
        position.update_profit_or_loss
        position.save
      end

      SYNCHRONIZE_PROPERTIES = [
        :pair_name, :units, :sell_or_buy,
        :entry_price, :entered_at, :closing_policy
      ].freeze

    end

  end
end
