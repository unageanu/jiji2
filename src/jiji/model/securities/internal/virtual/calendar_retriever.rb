# coding: utf-8

require 'oanda_api'
require 'jiji/model/securities/internal/oanda/converter'

module Jiji::Model::Securities::Internal::Virtual
  module CalendarRetriever
    def retrieve_calendar(period, pair_name = nil)
      @securities_provider.get.retrieve_calendar(period, pair_name)
    end
  end
end
