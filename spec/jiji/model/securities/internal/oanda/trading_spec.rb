# coding: utf-8

require 'jiji/test/test_configuration'

require 'jiji/model/securities/internal/examples/trading_examples'
require 'date'

describe Jiji::Model::Securities::Internal::Oanda::Trading do
  include_context 'use container'
  let(:wait) { 1 }
  let(:client) do
    Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end
  let(:backtest_id) { nil }
  let(:position_repository) do
    container.lookup(:position_repository)
  end

  today = Date.today
  it_behaves_like '建玉関連の操作' if today.wday >= 1 &&  today.wday < 6
end
