# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'

module Jiji::Model::Trading
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

    def to_h
      {
        take_profit:     take_profit,
        stop_loss:       stop_loss,
        trailing_stop:   trailing_stop,
        trailing_amount: trailing_amount
      }
    end

    def self.create(options)
      ClosingPolicy.new do |c|
        c.take_profit     = options[:take_profit]     || 0
        c.stop_loss       = options[:stop_loss]       || 0
        c.trailing_stop   = options[:trailing_stop]   || 0
        c.trailing_amount = options[:trailing_amount] || 0
      end
    end

    # for internal use.
    def extract_options_for_modify
      {
        stop_loss:     stop_loss,
        take_profit:   take_profit,
        trailing_stop: trailing_stop
      }
    end

    # for internal use.
    def should_close?(position)
      should_take_profit?(position) \
      || should_stop_loss?(position) \
      || should_trailing_stop?(position)
    end

    # for internal use.
    def update_price(position, pair)
      return if trailing_stop == 0
      price = BigDecimal.new(position.current_price, 10)
      amount = (trailing_stop * pair.pip)
      self.trailing_amount = calculate_trailing_amount(position, price, amount)
    end

    private

    def calculate_trailing_amount(position, price, amount)
      if position.sell_or_buy == :buy
        new_price = (price - amount).to_f
        trailing_amount == 0 ? new_price : [new_price, trailing_amount].max
      else
        new_price = (price + amount).to_f
        trailing_amount == 0 ? new_price : [new_price, trailing_amount].min
      end
    end

    def should_take_profit?(position)
      return false if take_profit == 0
      if position.sell_or_buy == :buy
        return position.current_price >= take_profit
      else
        return position.current_price <= take_profit
      end
    end

    def should_stop_loss?(position)
      return false if stop_loss == 0
      if position.sell_or_buy == :buy
        return position.current_price <= stop_loss
      else
        return position.current_price >= stop_loss
      end
    end

    def should_trailing_stop?(position)
      return false if trailing_amount == 0
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
