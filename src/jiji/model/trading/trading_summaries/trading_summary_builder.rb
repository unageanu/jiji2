# frozen_string_literal: true

require 'encase'

module Jiji::Model::Trading::TradingSummaries
  class TradingSummaryBuilder

    include Encase
    include Jiji::Errors

    needs :position_repository

    attr_accessor :page_size

    def initialize
      @sort_order = { entered_at: :asc, id: :asc }
      @page_size = 500
    end

    def build(backtest_id = nil, start_time = nil, end_time = nil)
      summary = TradingSummary.new
      filter  = create_filter(start_time, end_time)
      each_positions(backtest_id, filter) do |positions|
        summary.process_positions(positions)
      end
      summary
    end

    private

    def each_positions(backtest_id, filter_conditions)
      offset    = 0
      positions = nil
      while positions.nil? || !positions.empty?
        positions = @position_repository.retrieve_positions(
          backtest_id, @sort_order, offset, @page_size, filter_conditions)
        yield positions
        offset += @page_size
      end
    end

    def create_filter(start_time, end_time)
      filter = { :status.ne => :lost }
      filter[:entered_at.gte] = start_time unless start_time.nil?
      filter[:entered_at.lt]  = end_time   unless end_time.nil?
      filter
    end

  end
end
