module Jiji::Model::Trading::Internal
  module PositionInternalFunctions
    include Jiji::Model::Trading::Utils

    # for internal use.
    def update_state_for_reduce(units, time)
      return if status != :live
      self.units          = self.units - units
      self.updated_at     = time
      update_profit_or_loss
    end

    # for internal use.
    def update_state_to_closed(price = current_price, time = updated_at)
      return if status != :live
      self.exit_price     = price
      self.current_price  = price
      self.status         = :closed
      self.exited_at      = time
      self.updated_at     = time
      update_profit_or_loss
    end

    # for internal use.
    def update_state_to_lost(price = current_price, time = updated_at)
      return if status != :live
      self.current_price  = price
      self.status         = :lost
      self.updated_at     = time
      update_profit_or_loss
    end

    # for internal use.
    def update_price(tick)
      return if status != :live
      self.current_price = PricingUtils.calculate_current_price(
        tick, pair_name, sell_or_buy)
      self.updated_at = tick.timestamp
      update_profit_or_loss
    end

    # for internal use.
    def update_profit_or_loss
      self.profit_or_loss = calculate_profit_or_loss
      if max_drow_down.nil? || max_drow_down > profit_or_loss
        self.max_drow_down = profit_or_loss
      end
    end

    private

    def actual_amount_of(price)
      BigDecimal.new(price, 10) * units
    end

    def insert_trading_information_to_hash(h)
      h[:id]                   = id
      h[:internal_id]          = internal_id
      h[:pair_name]            = pair_name
      h[:units]                = units
      h[:sell_or_buy]          = sell_or_buy
      h[:status]               = status
      h[:profit_or_loss]       = profit_or_loss
    end

    def insert_price_and_time_information_to_hash(h)
      h[:entry_price]   = entry_price
      h[:current_price] = current_price
      h[:exit_price]    = exit_price
      h[:entered_at]    = entered_at
      h[:exited_at]     = exited_at
      h[:updated_at]    = updated_at
    end

    def insert_agent_information_to_hash(h)
      h[:agent] = agent ? agent.display_info : {}
    end

    def insert_backtest_information_to_hash(h)
      h[:backtest] = backtest ? backtest.display_info : {}
    end

    def calculate_profit_or_loss
      return nil if current_price.nil? || entry_price.nil?
      current = actual_amount_of(current_price)
      entry   = actual_amount_of(entry_price)
      (current - entry) * (sell_or_buy == :buy ? 1 : -1)
    end
  end
end
