# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/internal/examples/ordering_examples'
require 'jiji/model/securities/internal' \
        + '/examples/ordering_response_pattern_examples'

describe Jiji::Model::Securities::Internal::Virtual::Ordering do
  let(:wait) { 0 }
  let(:client) do
    Jiji::Test::VirtualSecuritiesBuilder.build
  end

  it_behaves_like '注文関連の操作'
  it_behaves_like '注文関連の操作(建玉がある場合のバリエーションパターン)'
end
