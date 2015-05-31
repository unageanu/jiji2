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
end
