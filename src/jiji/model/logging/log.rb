# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/pagenation'

module Jiji::Model::Logging
  class Log

    include Enumerable
    include Jiji::Utils::Pagenation

    def initialize(time_source, backtest_id = nil)
      @backtest_id = backtest_id
      @time_source = time_source
    end

    def get(index)
      query = Query.new(filter, { timestamp: :asc }, index, 1)
      data = query.execute(LogData)
      return @current if @current && data.length == index
      data[0]
    end

    def count
      count = LogData.where(filter).count
      @current ? count + 1 : count
    end

    def delete_before(time)
      LogData.where(filter.merge({ :timestamp.lte => time })).delete
    end

    def write(message)
      @current = create_log_data unless @current
      @current << message
      shift if @current.full?
    end

    def close
      save_current_log_data
    end

    private

    def shift
      save_current_log_data
      @current = create_log_data
    end

    def create_log_data
      LogData.create(@time_source.now, nil, @backtest_id)
    end

    def save_current_log_data
      @current.save if @current
      @current = nil
    end

    def filter
      { backtest_id: @backtest_id }
    end

  end
end
