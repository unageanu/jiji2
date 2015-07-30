module Jiji::Utils
  class Times

    def self.yesterday( time )
      round_day( time - 60 * 60 * 24)
    end

    def self.round_day( time )
      Time.new(time.year, time.mon, time.day, 0, 0, 0, time.utc_offset)
    end

  end
end
