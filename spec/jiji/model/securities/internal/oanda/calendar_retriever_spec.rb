# coding: utf-8

require 'jiji/test/test_configuration'

require 'jiji/model/securities/oanda_securities'
require 'jiji/model/securities/internal/examples/calendar_retriever_examples'
require 'date'

describe Jiji::Model::Securities::Internal::Oanda::CalendarRetriever do
  include_context 'use container'
  let(:client) do
    Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  it_behaves_like 'CalendarRetriever examples'
end if ENV['OANDA_API_ACCESS_TOKEN']
