# frozen_string_literal: true

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

    # for internal use.
    def self.create(options)
      ClosingPolicy.new do |c|
        c.take_profit     = options[:take_profit]     || 0
        c.stop_loss       = options[:stop_loss]       || 0
        c.trailing_stop   = options[:trailing_stop]   || 0
        c.trailing_amount = options[:trailing_amount] || 0
      end
    end

    def self.create_from_order(order, price) #:nodoc:
      create({
        stop_loss:       extract_stop_loss_from_order(order.stop_loss_on_fill, price),
        take_profit:     extract_take_profit_from_order(order.take_profit_on_fill),
        trailing_stop:   extract_trailing_stop_from_order(order.trailing_stop_loss_on_fill),
        trailing_amount: extract_trailing_amount_from_order(order.trailing_stop_loss_on_fill)
      })
    end

    def self.extract_stop_loss_from_order(stop_loss_on_fill, price)
      if stop_loss_on_fill
        if stop_loss_on_fill[:price]
          BigDecimal(stop_loss_on_fill[:price], 10)
        elsif stop_loss_on_fill[:distance]
          BigDecimal(price, 10) + stop_loss_on_fill[:distance]
        end
      else
        0
      end
    end

    def self.extract_take_profit_from_order(take_profit_on_fill)
      price = take_profit_on_fill && take_profit_on_fill[:price]
      price ? BigDecimal(price, 10) : 0
    end

    def self.extract_trailing_stop_from_order(trailing_stop_loss_on_fill)
      price = trailing_stop_loss_on_fill && trailing_stop_loss_on_fill[:distance]
      price ? BigDecimal(price, 10) : 0
    end

    def self.extract_trailing_amount_from_order(trailing_stop_loss_on_fill)
      price = trailing_stop_loss_on_fill && trailing_stop_loss_on_fill[:trailing_stop_value]
      price ? BigDecimal(price, 10) : 0
    end

    def self.create_from_trade(trade) #:nodoc:
      create({
        stop_loss:       extract_stop_loss_from_trade(trade),
        take_profit:     extract_take_profit_from_trade(trade),
        trailing_stop:   extract_trailing_stop_from_trade(trade),
        trailing_amount: extract_trailing_amount_from_trade(trade)
      })
    end

    def self.extract_stop_loss_from_trade(trade)
      price = trade["stopLossOrder"] && trade["stopLossOrder"]["price"]
      price ? BigDecimal(price, 10) : 0
    end

    def self.extract_take_profit_from_trade(trade)
      price = trade["takeProfitOrder"] && trade["takeProfitOrder"]["price"]
      price ? BigDecimal(price, 10) : 0
    end

    def self.extract_trailing_stop_from_trade(trade)
      price = trade["trailingStopLossOrder"] && trade["trailingStopLossOrder"]["distance"]
      price ? BigDecimal(price, 10) : 0
    end

    def self.extract_trailing_amount_from_trade(trade)
      price = trade["trailingStopLossOrder"] && trade["trailingStopLossOrder"]["trailingStopValue"]
      price ? BigDecimal(price, 10) : 0
    end

    # for internal use.
    def extract_options_for_modify #:nodoc:
      {
        stop_loss:     stop_loss,
        take_profit:   take_profit,
        trailing_stop: trailing_stop
      }
    end

    def update_from_order_options(options, price) #:nodoc:
      if options.include?(:stopLossOnFill)
        self.stop_loss = !options[:stopLossOnFill].nil? ? \
          ClosingPolicy.extract_stop_loss_from_order(options[:stopLossOnFill], price) : 0
      end
      if options.include?(:takeProfitOnFill)
        self.take_profit = !options[:takeProfitOnFill].nil? ? \
          ClosingPolicy.extract_take_profit_from_order(options[:takeProfitOnFill]) : 0
      end
      if options.include?(:trailingStopLossOnFill)
        self.trailing_stop = !options[:trailingStopLossOnFill].nil? ? \
          ClosingPolicy.extract_trailing_stop_from_order(options[:trailingStopLossOnFill]) : 0
        self.trailing_amount = !options[:trailingStopLossOnFill].nil? ? \
          ClosingPolicy.extract_trailing_amount_from_order(options[:trailingStopLossOnFill]) : 0
      end
    end

    # for internal use.
    def should_close?(position) #:nodoc:
      should_take_profit?(position) \
      || should_stop_loss?(position) \
      || should_trailing_stop?(position)
    end

    # for internal use.
    def update_price(position, pair) #:nodoc:
      return if trailing_stop&.zero?

      price = BigDecimal(position.current_price, 10)
      amount = (trailing_stop * pair.pip)
      self.trailing_amount = calculate_trailing_amount(position, price, amount)
    end

    private

    def calculate_trailing_amount(position, price, amount)
      if position.sell_or_buy == :buy
        new_price = (price - amount).to_f
        trailing_amount&.zero? ?
          new_price : [new_price, trailing_amount].max
      else
        new_price = (price + amount).to_f
        trailing_amount&.zero? ?
          new_price : [new_price, trailing_amount].min
      end
    end

    def should_take_profit?(position)
      return false if take_profit&.zero?
      if position.sell_or_buy == :buy
        return position.current_price >= take_profit
      else
        return position.current_price <= take_profit
      end
    end

    def should_stop_loss?(position)
      return false if stop_loss&.zero?
      if position.sell_or_buy == :buy
        return position.current_price <= stop_loss
      else
        return position.current_price >= stop_loss
      end
    end

    def should_trailing_stop?(position)
      return false if trailing_amount&.zero?
      if position.sell_or_buy == :buy
        return position.current_price <= trailing_amount
      else
        return position.current_price >= trailing_amount
      end
    end

    def values
      [
        take_profit,   stop_loss,
        trailing_stop, trailing_amount
      ]
    end

  end
end
