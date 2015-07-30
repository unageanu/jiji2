# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'singleton'

module Jiji::Model::Trading
  class Interval

    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable

    attr_reader :id, :ms

    def initialize(id, ms)
      @id = id
      @ms = ms
    end

    def calcurate_interval_start_time(time)
      step   = @ms / 1000
      offset = time.utc_offset
      t = Time.at(((time.to_i + offset) / step).floor * step - offset)
      t.localtime(time.utc_offset)
      t
    end

  end

  class Intervals

    include Jiji::Errors
    include Singleton

    def initialize
      @intervals = {}
      register_intervals
    end

    def all
      @intervals.values.sort_by { |i| i.ms }
    end

    def get(id)
      @intervals[id] || not_found
    end

    def resolve_collecting_interval(interval_id)
      get(interval_id).ms
    end

    private

    def register_intervals
      register_interval(:one_minute,            1)
      register_interval(:fifteen_minutes,      15)
      register_interval(:thirty_minutes,       30)
      register_interval(:one_hour,             60)
      register_interval(:six_hours,        6 * 60)
      register_interval(:one_day,         24 * 60)
    end

    def register_interval(id, m)
      @intervals[id] = Interval.new(id, m * 60 * 1000)
    end

  end
end
