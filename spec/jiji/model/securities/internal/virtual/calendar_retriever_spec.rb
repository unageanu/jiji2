# frozen_string_literal: true

require 'jiji/test/test_configuration'

require 'jiji/model/securities/oanda_securities'
require 'jiji/model/securities/internal/examples/calendar_retriever_examples'
require 'date'

if ENV['OANDA_API_ACCESS_TOKEN']
  describe Jiji::Model::Securities::Internal::Virtual::CalendarRetriever do
    include_context 'use backtests'
    let(:backtest_id) { backtests[0].id }
    let(:client) do
      Jiji::Test::VirtualSecuritiesBuilder.build(
        Time.utc(2015, 4, 1), Time.utc(2015, 4, 1, 6), backtest_id)
    end

    it_behaves_like 'CalendarRetriever examples'
  end
end
