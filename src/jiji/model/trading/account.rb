# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  # 口座情報
  class Account

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # アカウントID
    attr_accessor :account_id

    # アカウントの通貨
    attr_accessor :account_currency

    # 口座資産
    attr_accessor :balance

    # 合計損益
    attr_accessor :profit_or_loss
    # 必要証拠金
    attr_accessor :margin_used
    # 必要証拠金率
    attr_accessor :margin_rate
    # 最終更新時刻
    attr_accessor :updated_at

    def initialize(account_id, account_currency,
      balance, margin_rate, &init) #:nodoc:
      @account_id       = account_id
      @account_currency = account_currency
      @balance          = balance
      @margin_rate      = margin_rate

      @profit_or_loss = 0
      @margin_used    = 0

      yield self if block_given?
    end

    def +(other) #:nodoc:
      self.balance = (BigDecimal(balance, 10) + other).to_f
      self
    end

    def -(other) #:nodoc:
      self.balance = (BigDecimal(balance, 10) - other).to_f
      self
    end

    def update(positions, timestamp) #:nodoc:
      a = Aggregator.new(margin_rate)
      positions.each { |p| a.process(p) }
      self.margin_used    = a.margin_used
      self.profit_or_loss = a.profit_or_loss
      self.updated_at     = timestamp
    end

    class Aggregator #:nodoc:

      def initialize(margin_rate)
        @total_price    = BigDecimal(0, 10)
        @profit_or_loss = BigDecimal(0, 10)
        @margin_rate    = margin_rate
      end

      def process(position)
        return if position.status != :live
        @profit_or_loss += position.profit_or_loss || 0
        @total_price    +=
          BigDecimal(position.current_price || position.entry_price, 10) \
          * position.units
      end

      def margin_used
        @total_price * @margin_rate
      end

      def profit_or_loss
        @profit_or_loss.to_f
      end

    end

  end
end
