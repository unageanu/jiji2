# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  #== 注文
  class Order

    include Jiji::Errors
    include Jiji::Utils::ValueObject

    #=== 通貨ペア
    # 例) :EURUSD
    attr_reader :pair_name
    #=== 売りor買い ( :sell or :buy )
    attr_reader :sell_or_buy
    #=== 注文の内部識別用ID
    attr_reader :internal_id
    #=== 注文種別
    attr_reader :type
    #=== 最終更新時刻
    attr_reader :last_modified

    #=== 注文数
    attr_accessor :units
    #=== 執行価格(type)
    attr_accessor :price
    #=== 有効期限
    attr_accessor :expiry
    #=== 許容するスリッページの下限価格
    attr_accessor :lower_bound
    #=== 許容するスリッページの上限価格
    attr_accessor :upper_bound

    #=== 約定後のポジションを損切りする価格
    # 約定後、ポジションがこの価格になると(買いの場合は下回る、売りの場合は上回ると)
    # ポジションが決済されます
    attr_accessor :stop_loss
    #=== 約定後のポジションを利益確定する価格
    # 約定後、ポジションがこの価格になると(買いの場合は上回る、売りの場合は下回ると)
    # ポジションが決済されます
    attr_accessor :take_profit

    #=== トレーリングストップのディスタンス（pipsで小数第一位まで）
    attr_accessor :trailing_stop

    attr_accessor :broker

    def initialize(pair_name, internal_id, sell_or_buy, type, last_modified)
      @pair_name     = pair_name
      @internal_id   = internal_id
      @sell_or_buy   = sell_or_buy
      @type          = type
      @last_modified = last_modified
    end

    def save
      illegal_state unless @broker
      @broker.modify_order(self)
    end

    def cancel
      illegal_state unless @broker
      @broker.cancel_order(self)
    end

    private

    def values
      [
        @pair_name, @internal_id, @sell_or_buy, @type,
        @unit, @price, @lower_bound, @upper_bound,
        @stop_loss, @take_profit, @trailing_stop
      ]
    end

  end

  # 注文結果
  class OrderResult

    #=== 新規作成された注文
    # 注文が約定しなかった場合に返される
    attr_reader :order_opened

    #=== 新規建玉となった注文
    # 注文が約定し新しい建玉が生成された場合に返される
    attr_reader :trade_opened

    #=== 注文が約定した結果、既存の建玉の一部が決済された場合の、建玉の情報
    # 決済された注文があれば、その情報が ReducedPosition オブジェクトの形
    # で格納されます。
    attr_reader :trade_reduced
    attr_reader :trades_closed

    def initialize(order_opened, trade_opened, trade_reduced, trades_closed)
      @order_opened  = order_opened
      @trade_opened  = trade_opened
      @trade_reduced = trade_reduced
      @trades_closed = trades_closed
    end

  end

  #== 部分的に決済された建玉の情報
  class ReducedPosition

    #=== 決済された建玉の内部ID
    attr_reader :internal_id
    #=== 決済後の取引数
    attr_reader :units
    #=== 決済価格
    attr_reader :price
    #=== 決済時刻
    attr_reader :timestamp

    def initialize(internal_id, units, price, timestamp)
      @internal_id  = internal_id
      @units        = units
      @price        = price
      @timestamp    = timestamp
    end

  end

  #== すべて決済された建玉の情報
  class ClosedPosition

    #=== 決済された建玉の内部ID
    attr_reader :internal_id
    #=== 決済された取引数
    attr_reader :units
    #=== 決済価格
    attr_reader :price
    #=== 決済時刻
    attr_reader :timestamp

    def initialize(internal_id, units, price, timestamp)
      @internal_id  = internal_id
      @units        = units
      @price        = price
      @timestamp    = timestamp
    end

  end
end
