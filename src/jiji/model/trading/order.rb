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
    include Jiji::Web::Transport::Transportable

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

    def initialize(pair_name, internal_id, sell_or_buy, type, last_modified)
      @pair_name     = pair_name
      @internal_id   = internal_id
      @sell_or_buy   = sell_or_buy
      @type          = type
      @last_modified = last_modified
    end

    def attach_broker(broker)
      @broker = broker
    end

    def modify
      illegal_state unless @broker
      @broker.modify_order(self)
    end

    def cancel
      illegal_state unless @broker
      @broker.cancel_order(self)
    end

    def extract_options_for_modify
      options = extract_options
      insert_reservation_order_options(option) if type != :market
      options
    end

    def extract_options
      {
        units:         units,
        stop_loss:     stop_loss,
        take_profit:   take_profit,
        trailing_stop: trailing_stop
      }
    end

    def carried_out?(tick)
      current = Utils::PricingUtils
                .calculate_entry_price(tick, pair_name, sell_or_buy)
      case @type
      when :market     then true
      when :stop       then buying? ? upper?(current) : lower?(current)
      when :limit      then buying? ? lower?(current) : upper?(current)
      else market_if_touched?(current)
      end
    end

    private

    def buying?
      sell_or_buy == :buy
    end

    def lower?(current_price)
      current_price <= (price || 0)
    end

    def upper?(current_price)
      current_price >= (price || 0)
    end

    def market_if_touched?(curent_price)
      @initial_price = curent_price unless @initial_price
      @initial_price < price ? upper?(curent_price) : lower?(curent_price)
    end

    def insert_reservation_order_options(option)
      options[:price] = price
      options[:expiry] = expiry
      options[:lower_bound] = lower_bound
      options[:upper_bound] = upper_bound
    end

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

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    #=== 新規作成された注文
    # 注文が約定しなかった場合に返される
    attr_reader :order_opened

    #=== 新規建玉となった注文
    # 注文が約定し新しい建玉が生成された場合に返される
    attr_reader :trade_opened

    #=== 注文が約定した結果、既存の建玉の一部が決済された場合の建玉の情報
    # 決済された建玉の情報が ReducedPosition オブジェクトの形で格納されます。
    attr_reader :trade_reduced
    #=== 注文が約定した結果、既存の建玉が決済された場合の建玉の情報
    # 決済された建玉の情報が ClosedPosition オブジェクトの形で格納されます。
    attr_reader :trades_closed

    def initialize(order_opened, trade_opened, trade_reduced, trades_closed)
      @order_opened  = order_opened
      @trade_opened  = trade_opened
      @trade_reduced = trade_reduced
      @trades_closed = trades_closed
    end

  end

  class AbstractPositionResult

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    #=== 決済された建玉の内部ID
    attr_reader :internal_id
    #=== 取引数/部分決済の場合は、部分決済後の取引数
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

  #== 部分的に決済された建玉の情報
  class ReducedPosition < AbstractPositionResult

  end

  #== 全決済された建玉の情報
  class ClosedPosition < AbstractPositionResult

  end
end
