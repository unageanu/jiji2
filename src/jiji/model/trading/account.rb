# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'

module Jiji::Model::Trading
  class Account

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    # アカウントID
    attr_accessor :account_id

    # 口座資産
    attr_accessor :balance

    # 合計損益
    attr_accessor :profit_or_loss
    # 必要証拠金
    attr_accessor :margin_used
    # 証拠金率
    attr_accessor :margin_rate

    attr_accessor :updated_at

    def initialize( account_id, balance, margin_rate, &init )
      @account_id  = account_id
      @balance     = balance
      @margin_rate = margin_rate
      yield self if block_given?
    end

    def +(profit_or_loss)
      self.balance = (BigDecimal.new(self.balance, 10) + profit_or_loss).to_f
      self
    end

    def -(profit_or_loss)
      self.balance = (BigDecimal.new(self.balance, 10) - profit_or_loss).to_f
      self
    end

    def update( positions, timestamp )
      self.updated_at     = timestamp
      total_price         = BigDecimal.new(0, 10)
      self.profit_or_loss = BigDecimal.new(0, 10)
      positions.each do |p|
        total_price         += BigDecimal.new(p.entry_price, 10) * p.units
        self.profit_or_loss += p.profit_or_loss
      end
      self.margin_used = total_price * margin_rate
    end

  end
end
