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

    # 指定した期間、通貨ペアのレート情報(4本値 + 出来高)を取得します。
    # 一度に最大5000件のデータを取得できます。
    #
    # pair_name:: 取得対象の通貨ペア名 例) :USDJPY, :EURJPY
    # interval:: レートを集計する期間。以下のいずれかを指定できます。
    #            * :fifteen_seconds .. 15秒足
    #            * :one_minute      .. 分足
    #            * :fifteen_minutes .. 15分足
    #            * :thirty_minutes  .. 30分足
    #            * :one_hour        .. 1時間足
    #            * :six_hours       .. 6時間足
    #            * :one_day         .. 日足
    # start_time:: 取得開始日時。 Time 型で指定します。
    # end_time:: 取得終了日時。 Time 型で指定します。
    #
    # 戻り値:: Rate の配列
    def retrieve_rates(pair_name,
      interval, start_time, end_time)
      securities.retrieve_rate_history(pair_name,
        interval, start_time, end_time)
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
      return @orders if !@orders_is_dirty && @orders
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
      @orders_is_dirty = true
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
    # 戻り値:: ClosedPosition
    def close_position(position)
      result = securities.close_trade(position.internal_id)
      @positions.apply_close_result(result)
      @positions_is_dirty = true
      ClosedPosition.new(result.internal_id,
        position.units, result.price, result.timestamp, result.profit_or_loss)
    end

    # 経済カレンダー情報を取得します。
    # 詳細は、以下をご覧ください。
    #
    # http://developer.oanda.com/docs/jp/v1/forex-labs/#section
    #
    # ※現在時刻を起点とした情報のみ取得できます。
    # バックテスト内でも実行することはできますが、返されるのは<b>テスト内の時間時点の情報で
    # はない</b>のでご注意ください。
    #
    # period:: カレンダーデータを取得する期間。以下のいずれかを指定できます。
    #          * 3600 .. 1時間
    #          * 43200 .. 12時間
    #          * 86400 .. 1日
    #          * 604800 .. 1週間
    #          * 2592000 .. 1ヶ月
    #          * 7776000 .. 3ヶ月
    #          * 15552000 .. 6ヶ月
    #          * 31536000 .. 1年
    # pair_name:: 取得対象とする通貨ペアの名前。
    #             例) USDJPY
    #             指定がない場合、すべての通貨ペアの情報を取得します。
    # 戻り値:: EconomicCalendarInformation の配列
    def retrieve_economic_calendar_informations(period, pair_name = nil)
      securities.retrieve_calendar(period, pair_name)
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

    # 建玉情報を更新します。
    #
    # 証券会社へのアクセスを削減するため、建玉情報は1分間キャッシュされます。
    # 最新の情報を参照したい場合、このAPIを呼び出しください。
    #
    # 戻り値:: Positions
    def load_positions
      positions = securities.retrieve_trades
      @positions.update(positions)
      @positions.update_price(tick, pairs)
      @positions_is_dirty = false
      @positions.each { |p| p.attach_broker(self) }
      @positions
    end

    private

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
