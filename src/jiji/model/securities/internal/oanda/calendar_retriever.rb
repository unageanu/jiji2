# frozen_string_literal: true

require 'oanda_api'
require 'jiji/model/securities/internal/oanda/converter'

module Jiji::Model::Securities::Internal::Oanda
  module CalendarRetriever
    def retrieve_calendar(period, pair_name = nil)
      parameter = { period: period }
      if pair_name
        parameter[:instrument] =
          Converter.convert_pair_name_to_instrument(pair_name)
      end
      @client.calendar(parameter).get.map do |info|
        Jiji::Model::Trading::EconomicCalendarInformation.new(info)
      end
    end
  end
end
