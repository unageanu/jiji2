# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

RSpec.shared_examples 'CalendarRetriever examples' do
  describe '#retirieve_calendar' do
    it 'can retirieve financial event informations.' do
      check_event_information(client.retrieve_calendar(2592000, :USDJPY))
      check_event_information(client.retrieve_calendar(604800))
    end

    def check_event_information(events)
      events.each do |event|
        expect(event.title).not_to be nil
        expect(event.currency).not_to be nil
        expect(event.region).not_to be nil
        expect(event.unit).not_to be nil
        expect(event.timestamp).not_to be nil
      end
    end

  end
end
