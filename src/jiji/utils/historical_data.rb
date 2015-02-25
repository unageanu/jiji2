require 'date'

module Jiji::Utils
  class HistoricalData

    def initialize(sorted_data, start_time, end_time)
      @data       = sorted_data
      @start_time = start_time
      @end_time   = end_time
    end

    def get_at(timestamp)
      check_period(timestamp)
      @data.bsearch { |s| s.timestamp <= timestamp }
    end

    private

    def check_period(timestamp)
      return if timestamp >= @start_time && timestamp <= @end_time
      HistoricalData.out_of_period(timestamp)
    end

    def self.load(data_type, start_time, end_time)
      start_time = calculate_start_time(data_type, start_time)
      data_type.where(
        :timestamp.gte => start_time,
        :timestamp.lte => end_time
      ).order_by(:timestamp.desc)
    end

    def self.calculate_start_time(data_type, start_time)
      # 開始時点のswapを必ず含めるため、
      # 開始より以前で最大のstart_timeを再計算する
      first = data_type.where(:timestamp.lte => start_time)
              .order_by(:timestamp.desc).only(:timestamp).first
      out_of_period(start_time) unless first
      first.timestamp
    end

    def self.out_of_period(timestamp)
      fail ArgumentError, "out of period. time=#{timestamp}"
    end

  end
end
