# frozen_string_literal: true

require 'tzinfo'
require 'tzinfo'

module Jiji::Utils
  class Times

    extend Jiji::Errors

    def self.yesterday(time)
      round_day(time - 60 * 60 * 24)
    end

    def self.round_day(time)
      Time.new(time.year, time.mon, time.day, 0, 0, 0, time.utc_offset)
    end

    def self.iana_name(time)
      ZONE_MAP[time.utc_offset / 60] || illegal_argument
    end

    ZONE_MAP = {
      -12 * 60 => 'Etc/GMT+12',
      -11 * 60 => 'US/Samoa',
      -10 * 60 => 'US/Hawaii',
      -9 * 60 - 30 => 'Pacific/Marquesas',
      -9 * 60 => 'US/Alaska',
      -8 * 60 => 'US/Pacific',
      -7 * 60 => 'US/Arizona',
      -6 * 60 => 'US/Central',
      -5 * 60 => 'US/Michigan',
      -4 * 60 - 30 => 'America/Caracas',
      -4 * 60 => 'America/Grenada',
      -3 * 60 - 30 => 'America/St_Johns',
      -3 * 60 => 'America/Maceio',
      -2 * 60 => 'America/Noronha',
      -1 * 60 => 'America/Scoresbysund',
      0 * 60 => 'UTC',
      1 * 60 => 'Europe/Amsterdam',
      2 * 60 => 'Europe/Kaliningrad',
      3 * 60 => 'Europe/Moscow',
      3 * 60 + 30 => 'Asia/Tehran',
      4 * 60 => 'Asia/Muscat',
      4 * 60 + 30 => 'Asia/Kabul',
      5 * 60 => 'Asia/Samarkand',
      5 * 60 + 30 => 'Asia/Calcutta',
      5 * 60 + 45 => 'Asia/Kathmandu',
      6 * 60 => 'Asia/Urumqi',
      6 * 60 + 30 => 'Asia/Rangoon',
      7 * 60 => 'Asia/Jakarta',
      8 * 60 => 'Asia/Hong_Kong',
      8 * 60 + 45 => 'Australia/Eucla',
      9 * 60 => 'Asia/Tokyo',
      9 * 60 + 30 => 'Australia/Darwin',
      10 * 60 => 'Asia/Magadan',
      10 * 60 + 30 => 'Australia/Lord_Howe',
      11 * 60 => 'Pacific/Noumea',
      11 * 60 + 30 => 'Pacific/Norfolk',
      12 * 60 => 'Pacific/Nauru',
      12 * 60 + 45 => 'Pacific/Chatham',
      13 * 60 => 'Pacific/Fakaofo',
      14 * 60 => 'Pacific/Kiritimati'
    }.freeze

  end
end
