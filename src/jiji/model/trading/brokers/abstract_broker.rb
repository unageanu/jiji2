# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Model::Trading::Brokers
  class AbstractBroker

    include Jiji::Model::Trading

    attr_reader :positions #:nodoc:
    # 口座情報
    attr_reader :account

    def initialize #:nodoc:
      @positions_is_dirty = true
      @orders_is_dirty    = true
    end

    # 通貨ペアの一覧を取得します
    #
    # 戻り値:: Pair の配列
    def pairs
      @pairs_cache ||= securities.retrieve_pairs
    end

    # 現在のレートを取得します
    #
    # 戻り値:: Tick
    def tick
      @rates_cache ||= securities.retrieve_current_tick
    end

    # 建玉一覧を取得します
    #
    # 戻り値:: Positions
    def positions
      return @positions unless @positions_is_dirty
      load_positions
    end

    # 注文一覧を取得します
    #
    # 戻り値:: Order の配列
    def orders
      return @orders  if !@orders_is_dirty && @orders
      load_orders
    end

    def buy(pair_name, units,
      type = :market, options = {}, agent = nil) #:nodoc:
      order(pair_name, :buy, units, type, options, agent)
    end

    def sell(pair_name, units,
      type = :market, options = {}, agent = nil) #:nodoc:
      order(pair_name, :sell, units, type, options, agent)
    end

    # 注文の変更を反映します。
    # order:: 注文
    def modify_order(order)
      securities.modify_order(
        order.internal_id, order.extract_options_for_modify)
      order
    end

    # 注文をキャンセルします。
    # order:: 注文
    def cancel_order(order)
      result = securities.cancel_order(order.internal_id)
      @orders_is_dirty    = true
      result
    end

    # 建玉の変更を反映します。
    # position:: 建玉
    def modify_position(position)
      securities.modify_trade(
        position.internal_id,
        position.closing_policy.extract_options_for_modify)
      position.save
      position
    end

    # 建玉を決済します。
    # position:: 建玉
    def close_position(position)
      result = securities.close_trade(position.internal_id)
      @positions.apply_close_result(result)
      @positions_is_dirty = true
      ClosedPosition.new(result.internal_id,
        position.units, result.price, result.timestamp)
    end

    def destroy #:nodoc:
      securities.destroy if securities
    end

    # for internal use.
    def refresh #:nodoc:
      @rates_cache = nil
      @orders_is_dirty = true
      @positions.update_price(tick, pairs) if next?
    end

    # for internal use.
    def refresh_positions #:nodoc:
      @positions_is_dirty = true
    end

    # for internal use.
    def refresh_account #:nodoc:
    end

    private

    def load_positions
      positions = securities.retrieve_trades
      @positions.update(positions)
      @positions.update_price(tick, pairs)
      @positions_is_dirty = false
      @positions.each { |p| p.attach_broker(self) }
      @positions
    end

    def load_orders
      @orders = securities.retrieve_orders
      @orders.each { |o| o.attach_broker(self) }
      @orders_is_dirty = false
      @orders
    end

    def order(pair_id, sell_or_buy, units, type, options, agent)
      result = securities.order(pair_id, sell_or_buy, units, type, options)
      @positions_is_dirty = true
      @orders_is_dirty    = true
      @positions.apply_order_result(result, tick, agent)
      result
    end

    def init_positions(initial_positions = [])
      @positions = Positions.new(initial_positions, position_builder, account)
    end

  end
end
