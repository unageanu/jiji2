# coding: utf-8

require 'encase'
require 'thread'

module Jiji::Model::Trading::TradingSummaries
  class CompositeSummary

    def initialize(name = nil)
      @categories = create_categories
      @name       = name
    end

    def process(position)
      @categories.each do |category|
        category.process(position)
      end
    end

    def to_h
      initial_value = @name ? { name: @name } : {}
      @categories.each_with_object(initial_value) do |category, r|
        r[category.name] = category.to_h
      end
    end

    private

    def create_categories
      [
        States.new,
        WinsAndLosses.new,
        SellOrBuy.new,
        Pairs.new,
        Units.new,
        ProfitOrLoss.new,
        HoldingPeriod.new
      ]
    end

  end

  class TradingSummary < CompositeSummary

    include Jiji::Web::Transport::Transportable

    def process_positions(positions)
      positions.each { |p| process(p) }
    end

    private

    def create_categories
      super + [AgentSummary.new]
    end

  end

  class Category

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def process(position)
    end

    def calculate_avg(sum, count)
      count > 0 ? (sum / count) : 0
    end

  end

  class AgentSummary < Category

    def initialize
      super(:agent_summary)
      @agent_summary = {}
    end

    def process(position)
      agent_id   = (position.agent && position.agent.id) || ''
      agent_name = (position.agent && position.agent.name) || ''
      unless @agent_summary.include?(agent_id)
        @agent_summary[agent_id] = CompositeSummary.new(agent_name)
      end
      @agent_summary[agent_id].process(position)
    end

    def to_h
      @agent_summary.each_with_object({}) do |pair, r|
        r[pair[0]] = pair[1].to_h
      end
    end

  end

  class WinsAndLosses < Category

    def initialize
      super(:wins_and_losses)
      @win   = 0
      @lose  = 0
      @draw  = 0
    end

    def process(position)
      if position.profit_or_loss > 0
        @win  += 1
      elsif position.profit_or_loss < 0
        @lose += 1
      else
        @draw += 1
      end
    end

    def to_h
      {
        win:  @win,
        lose: @lose,
        draw: @draw
      }
    end

  end

  class States < Category

    def initialize
      super(:states)
      @count  = 0
      @exited = 0
    end

    def process(position)
      @count  += 1
      @exited += 1 unless position.exited_at.nil?
    end

    def to_h
      {
        count:  @count,
        exited: @exited
      }
    end

  end

  class SellOrBuy < Category

    def initialize
      super(:sell_or_buy)
      @sell = 0
      @buy  = 0
    end

    def process(position)
      if position.sell_or_buy == :sell
        @sell += 1
      else
        @buy  += 1
      end
    end

    def to_h
      {
        sell: @sell,
        buy:  @buy
      }
    end

  end

  class Pairs < Category

    def initialize
      super(:pairs)
      @pairs = {}
    end

    def process(position)
      pair = position.pair_name
      if @pairs.include?(pair)
        @pairs[pair] += 1
      else
        @pairs[pair] = 1
      end
    end

    def to_h
      @pairs
    end

  end

  class ProfitOrLoss < Category

    def initialize
      super(:profit_or_loss)
      @max_profit   = nil
      @max_loss     = nil
      @total_profit = BigDecimal.new(0, 10)
      @total_loss   = BigDecimal.new(0, 10)
      @win_count    = 0
      @lose_count   = 0
    end

    def process(position)
      profit_or_loss = BigDecimal.new(position.profit_or_loss, 10)
      update_max_profit_and_max_loss(profit_or_loss)
      update_total_profit_and_total_loss(profit_or_loss)
    end

    def update_max_profit_and_max_loss(profit)
      @max_profit = profit if @max_profit.nil? || @max_profit < profit
      @max_loss = profit   if @max_loss.nil?   || @max_loss > profit
    end

    def update_total_profit_and_total_loss(profit_or_loss)
      if profit_or_loss > 0
        @total_profit += profit_or_loss
        @win_count += 1
      elsif profit_or_loss < 0
        @total_loss += profit_or_loss
        @lose_count += 1
      end
    end

    def to_h
      {
        max_profit:           @max_profit,
        max_loss:             @max_loss,
        avg_profit:           calculate_avg(@total_profit, @win_count),
        avg_loss:             calculate_avg(@total_loss,   @lose_count),
        total_profit:         @total_profit,
        total_loss:           @total_loss,
        total_profit_or_loss: @total_profit + @total_loss,
        profit_factor:        calculate_profit_factor
      }
    end

    def calculate_profit_factor
      return 0 if @total_loss == 0
      @total_profit / (@total_loss * -1)
    end

  end

  class HoldingPeriod < Category

    def initialize
      super(:holding_period)
      @total_period = BigDecimal.new(0, 10)
      @max_period   = nil
      @min_period   = nil
      @count = 0
    end

    def process(position)
      return unless position.exited_at
      period = position.exited_at.to_i - position.entered_at.to_i
      update_max_and_min(period)
      update_total_period(period)
    end

    def update_max_and_min(period)
      @max_period = period if @max_period.nil? || @max_period < period
      @min_period = period if @min_period.nil? || @min_period > period
    end

    def update_total_period(period)
      @total_period += period
      @count += 1
    end

    def to_h
      {
        max_period: @max_period,
        min_period: @min_period,
        avg_period: calculate_avg(@total_period, @count)
      }
    end

  end

  class Units < Category

    def initialize
      super(:units)
      @total_units = BigDecimal.new(0, 10)
      @max_units   = nil
      @min_units   = nil
      @count = 0
    end

    def process(position)
      units = position.units
      update_max_and_min(units)
      update_total_units(units)
    end

    def update_max_and_min(units)
      @max_units = units if @max_units.nil? || @max_units < units
      @min_units = units if @min_units.nil? || @min_units > units
    end

    def update_total_units(units)
      @total_units += units
      @count += 1
    end

    def to_h
      {
        max_units: @max_units,
        min_units: @min_units,
        avg_units: calculate_avg(@total_units, @count)
      }
    end

  end
end
