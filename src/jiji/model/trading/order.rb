# frozen_string_literal: true

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  # 注文
  # ※各フィールドについて、詳しくは <a href="http://developer.oanda.com/rest-live-v20/order-df/">公式リファレンス</a> を参照ください。
  class Order

    include Jiji::Errors
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # 通貨ペア
    # 例) :EURUSD
    attr_reader :pair_name
    # 売りor買い ( :sell or :buy )
    attr_reader :sell_or_buy
    # 注文の内部識別用ID
    attr_reader :internal_id
    # 注文種別
    attr_reader :type

    # 最終更新時刻
    attr_accessor :last_modified
    # 注文数
    attr_accessor :units
    # 執行価格
    attr_accessor :price

    attr_accessor :time_in_force
    attr_accessor :gtd_time

    attr_accessor :price_bound
    attr_accessor :position_fill
    attr_accessor :trigger_condition

    attr_accessor :take_profit_on_fill
    attr_accessor :stop_loss_on_fill
    attr_accessor :trailing_stop_loss_on_fill

    attr_accessor :client_extensions
    attr_accessor :trade_client_extensions

    def initialize(pair_name, internal_id,
      sell_or_buy, type, last_modified) #:nodoc:
      @pair_name     = pair_name
      @internal_id   = internal_id
      @sell_or_buy   = sell_or_buy
      @type          = type
      @last_modified = last_modified
      @units = @price = @time_in_force = @gtd_time = nil
      @price_bound = @position_fill = @trigger_condition = nil
      @take_profit_on_fill = @stop_loss_on_fill = @trailing_stop_loss_on_fill = nil
      @client_extensions = @trade_client_extensions = nil
    end

    def attach_broker(broker) #:nodoc:
      @broker = broker
    end

    # 注文の変更を反映します。
    def modify
      illegal_state unless @broker
      @broker.modify_order(self)
    end

    # 注文をキャンセルします。
    def cancel
      illegal_state unless @broker
      @broker.cancel_order(self)
    end

    def extract_options_for_modify #:nodoc:
      options = extract_options
      insert_reservation_order_options(options) if type != :market
      options
    end

    def extract_options #:nodoc:
      %i[
        units time_in_force position_fill trigger_condition
        take_profit_on_fill stop_loss_on_fill trailing_stop_loss_on_fill
        client_extensions trade_client_extensions
      ].each_with_object({}) do |key, r|
        r[key] = method(key).call
      end
    end

    def expired?(timestamp) #:nodoc:
      time_in_force == 'GTD' && gtd_time && gtd_time <= timestamp
    end

    def carried_out?(tick) #:nodoc:
      current = Utils::PricingUtils
        .calculate_entry_price(tick, pair_name, sell_or_buy)
      case @type
      when :market     then true
      when :stop       then buying? ? upper?(current) : lower?(current)
      when :limit      then buying? ? lower?(current) : upper?(current)
      else market_if_touched?(current)
      end
    end

    def values #:nodoc:
      [
        @pair_name, @internal_id, @sell_or_buy, @type,
        @last_modified, @units, @price, @time_in_force, @gtd_time,
        @price_bound, @position_fill, @trigger_condition,
        @take_profit_on_fill, @stop_loss_on_fill, @trailing_stop_loss_on_fill,
        @client_extensions, @trade_client_extensions
      ]
    end

    def from_h(hash)
      hash.each do |k, v|
        k = k.to_sym
        unless v.nil?
          if k == :price || k == :price_bound || k == :initial_price
            v = BigDecimal(v, 10)
          end
          if k == :take_profit_on_fill || k == :stop_loss_on_fill || k == :trailing_stop_loss_on_fill
            v = v.clone.symbolize_keys
            v[:price] = BigDecimal(v[:price], 10) if v[:price]
          end
        end

        key = '@' + k.to_s
        instance_variable_set(key, v) if instance_variable_defined?(key)
      end
    end

    def collect_properties(keys = instance_variables.map { |n| n[1..-1].to_sym })
      keys.each_with_object({}) do |name, obj|
        next if name == :broker

        v = instance_variable_get("@#{name}")

        unless v.nil?
          if name == :price || name == :price_bound || name == :initial_price
            v = v.to_s
          end
          if name == :take_profit_on_fill || name == :stop_loss_on_fill || name == :trailing_stop_loss_on_fill
            v = v.clone
            v[:price] = v[:price].to_s if v[:price]
          end
        end

        obj[name] = v
      end
    end

    def collect_properties_for_modify
      instance_variables.map { |n| n[1..-1].to_sym }.each_with_object({}) do |name, obj|
        next if name == :broker

        v = instance_variable_get("@#{name}")
        obj[name] = v.is_a?(Hash) ? v.dup : v
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

    def market_if_touched?(current_price)
      @initial_price ||= current_price
      @initial_price < price ? upper?(current_price) : lower?(current_price)
    end

    def insert_reservation_order_options(options)
      options[:price] = price
      options[:gtd_time] = gtd_time
      options[:price_bound] = price_bound
    end

  end

  # 注文結果
  class OrderResult

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # 新規作成された注文( Jiji::Model::Trading::Order )
    # * 注文が約定しなかった場合に返されます
    # * 約定した場合、nil が返されます。
    attr_reader :order_opened

    # 注文によって作成された建玉 ( Jiji::Model::Trading::Position )
    # * 注文が約定し、新しい建玉が生成された場合に返されます
    # * 約定しなかった場合、nil が返されます。
    attr_reader :trade_opened

    # 注文が約定した結果、既存の建玉の一部が決済された場合の建玉の情報
    # * 決済された建玉の情報を示す ReducedPosition オブジェクトです。
    attr_reader :trade_reduced
    # 注文が約定した結果、既存の建玉が決済された場合の建玉の情報
    # * 決済された建玉の情報が ClosedPosition オブジェクトの配列で格納されます。
    attr_reader :trades_closed

    def initialize(order_opened,
      trade_opened, trade_reduced, trades_closed) #:nodoc:
      @order_opened  = order_opened
      @trade_opened  = trade_opened
      @trade_reduced = trade_reduced
      @trades_closed = trades_closed
    end

  end

  class AbstractPositionResult

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # 決済された建玉の内部ID
    attr_reader :internal_id
    # 取引数/部分決済の場合は、部分決済された取引数
    attr_reader :units
    # 決済価格
    attr_reader :price
    # 決済時刻
    attr_reader :timestamp
    # 最終損益
    attr_reader :profit_or_loss

    def initialize(internal_id, units,
      price, timestamp, profit_or_loss) #:nodoc:
      @internal_id    = internal_id
      @units          = units
      @price          = price
      @timestamp      = timestamp
      @profit_or_loss = profit_or_loss
    end

  end

  # 部分的に決済された建玉の情報
  class ReducedPosition < AbstractPositionResult

  end

  # 全決済された建玉の情報
  class ClosedPosition < AbstractPositionResult

  end
end
