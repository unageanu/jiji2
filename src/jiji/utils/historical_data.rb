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

    def self.load_data(start_time, end_time, data_type)
      data = Jiji::Utils::HistoricalData.load(data_type, start_time, end_time)
      data = partition_by_pair(data)
      data = aggregate_by_pair(data, start_time, end_time)
      data
    end

    private

    def self.partition_by_pair(data)
      data.each_with_object({})do |v, r|
        r[v.pair_id] = [] unless r.include?(v.pair_id)
        r[v.pair_id] << v
      end
    end

    def self.aggregate_by_pair(data, start_time, end_time)
      data.each_with_object({})do |v, r|
        r[v[0]] =  Jiji::Utils::HistoricalData.new(v[1], start_time, end_time)
      end
    end

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
