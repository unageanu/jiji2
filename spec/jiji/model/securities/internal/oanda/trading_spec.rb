# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/internal/examples/trading_examples'

describe Jiji::Model::Securities::Internal::Oanda::Trading do
  let(:wait) { 1 }
  let(:client) do
    Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  it_behaves_like '建玉関連の操作'
end
