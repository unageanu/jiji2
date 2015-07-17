# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/pagenation'

module Jiji::Model::Logging
  class Log

    include Jiji::Utils::Pagenation

    def initialize(time_source, backtest_id = nil)
      @backtest_id = backtest_id
      @time_source = time_source
    end

    def get(index, order = :asc)
      query = Query.new(filter, { timestamp: order }, index, 1)
      data = query.execute(LogData)
      data && data.length > 0 ? data[0] : nil
    end

    def count
      LogData.where(filter).count
    end

    def delete_before(time)
      LogData.where(filter.merge({ :timestamp.lte => time })).delete
    end

    def each
      query = Query.new(filter, { timestamp: :asc })
      query.execute(LogData).each do |data|
        yield data
      end
    end

    def write(message)
      @current = create_or_open_log_data unless @current
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

    def latest_data
      get(0, :desc)
    end

    def create_or_open_log_data
      latest = latest_data
      if latest && !latest.full?
        latest
      else
        create_log_data
      end
    end

    def create_log_data
      data = LogData.create(@time_source.now, nil, @backtest_id)
      data.save
      return data
    end

    def save_current_log_data
      @current.save if @current
    end

    def filter
      { backtest_id: @backtest_id }
    end

  end
end
