require 'date'

module Jiji
module Utils
  
  class HistoricalData
    
    def initialize( sorted_data, start_time, end_time )
      @data       = sorted_data
      @start_time = start_time
      @end_time   = end_time
    end
    
    def get_at( timestamp )
      check_period( timestamp )
      return @data.bsearch {|s| s.timestamp <= timestamp }
    end
    
  private 
    def check_period(timestamp)
      unless timestamp >= @start_time && timestamp <= @end_time
        raise ArgumentError.new(
          "out of period. time=#{timestamp} start=#{@start_time} end=#{@start_time}")
      end
    end
    
    def self.load(data_type, start_time, end_time)
      start_time = caluculate_start_time(data_type, start_time)
      return data_type.where( 
        :timestamp.gte => start_time, 
        :timestamp.lte => end_time
      ).order_by(:timestamp.desc)
    end
    
    def self.caluculate_start_time(data_type, start_time)
      # 開始時点のswapを必ず含めるため、
      # 開始より以前で最大のstart_timeを再計算する
      first = data_type.where( :timestamp.lte => start_time )
        .order_by(:timestamp.desc).only(:timestamp).first
      out_of_period(start_time) unless first
      return first.timestamp
    end
    
    def self.out_of_period(timestamp) 
       raise ArgumentError.new("out of period. time=#{timestamp}")
    end
    
  end
  
end
end