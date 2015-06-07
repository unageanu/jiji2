# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/internal/examples/trading_examples'

describe Jiji::Model::Securities::Internal::Virtual::Trading do
  let(:wait) { 0 }
  let(:container) do
    Jiji::Test::TestContainerFactory.instance.new_container
  end
  let(:data_builder) do Jiji::Test::DataBuilder.new end
  let(:backtest_id) do
    backtest_repository  = container.lookup(:backtest_repository)
    position_repository  = container.lookup(:position_repository)
    registory            = container.lookup(:agent_registry)

    registory.add_source('aaa', '', :agent, data_builder.new_agent_body(1))

    data_builder.register_backtest(1, backtest_repository).id
  end
  let(:client) do
    Jiji::Test::VirtualSecuritiesBuilder.build(
      Time.utc(2015, 4, 1), Time.utc(2015, 4, 1, 6), backtest_id)
  end
  let(:position_repository) do
    container.lookup(:position_repository)
  end

  after(:example) do
    data_builder.clean
  end

  it_behaves_like '建玉関連の操作'
end
