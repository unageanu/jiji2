# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/internal/examples/trading_examples'

describe Jiji::Model::Securities::Internal::Virtual::Trading do
  let(:wait) { 0 }
  let(:client) do
    Jiji::Test::VirtualSecuritiesBuilder.build
  end

  it_behaves_like '建玉関連の操作'
end
