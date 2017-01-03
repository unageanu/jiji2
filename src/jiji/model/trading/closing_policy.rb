# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'

module Jiji::Model::Trading
  # 決済条件
  class ClosingPolicy

    include Mongoid::Document
    include Jiji::Errors
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Utils

    embedded_in :position

    field :take_profit,     type: Float, default: 0
    field :stop_loss,       type: Float, default: 0
    field :trailing_stop,   type: Float, default: 0
    field :trailing_amount, type: Float, default: 0

    def to_h #:nodoc:
      {
        take_profit:     take_profit,
        stop_loss:       stop_loss,
        trailing_stop:   trailing_stop,
        trailing_amount: trailing_amount
      }
    end

    # Hashの値から、新しい ClosingPolicy を作成します。
    #
    #  Jiji::Model::Trading::ClosingPolicy.create({
    #    stop_loss:     130,
    #    take_profit:   140.5,
    #    trailing_stop: 10
    #  })
    #
    # options:: 値
    # 戻り値:: 新しい ClosingPolicy
    def self.create(options)
      ClosingPolicy.new do |c|
        c.take_profit     = options[:take_profit]     || 0
        c.stop_loss       = options[:stop_loss]       || 0
        c.trailing_stop   = options[:trailing_stop]   || 0
        c.trailing_amount = options[:trailing_amount] || 0
      end
    end

    def self.create_from_trade(trade) #:nodoc:
      create({
        stop_loss:       trade.stop_loss,
        take_profit:     trade.take_profit,
        trailing_stop:   trade.trailing_stop,
        trailing_amount: trade.trailing_amount
      })
    end

    # for internal use.
    def extract_options_for_modify #:nodoc:
      {
        stop_loss:     stop_loss,
        take_profit:   take_profit,
        trailing_stop: trailing_stop
      }
    end

    # for internal use.
    def should_close?(position) #:nodoc:
      should_take_profit?(position) \
      || should_stop_loss?(position) \
      || should_trailing_stop?(position)
    end

    # for internal use.
    def update_price(position, pair) #:nodoc:
      return if trailing_stop && trailing_stop.zero?
      price = BigDecimal.new(position.current_price, 10)
      amount = (trailing_stop * pair.pip)
      self.trailing_amount = calculate_trailing_amount(position, price, amount)
    end

    private

    def calculate_trailing_amount(position, price, amount)
      if position.sell_or_buy == :buy
        calculate_trailing_amount_for_buying(position, price, amount)
      else
        calculate_trailing_amount_for_selling(position, price, amount)
      end
    end

    def calculate_trailing_amount_for_buying(position, price, amount)
      new_price = (price - amount).to_f
      trailing_amount && trailing_amount.zero? ?
        new_price : [new_price, trailing_amount].max
    end

    def calculate_trailing_amount_for_selling(position, price, amount)
      new_price = (price + amount).to_f
      trailing_amount && trailing_amount.zero? ?
        new_price : [new_price, trailing_amount].min
    end

    def should_take_profit?(position)
      return false if take_profit && take_profit.zero?
      if position.sell_or_buy == :buy
        return position.current_price >= take_profit
      else
        return position.current_price <= take_profit
      end
    end

    def should_stop_loss?(position)
      return false if stop_loss && stop_loss.zero?
      if position.sell_or_buy == :buy
        return position.current_price <= stop_loss
      else
        return position.current_price >= stop_loss
      end
    end

    def should_trailing_stop?(position)
      return false if trailing_amount && trailing_amount.zero?
      if position.sell_or_buy == :buy
        return position.current_price <= trailing_amount
      else
        return position.current_price >= trailing_amount
      end
    end

    def values
      [take_profit, stop_loss, trailing_stop, trailing_amount]
    end

  end
end
