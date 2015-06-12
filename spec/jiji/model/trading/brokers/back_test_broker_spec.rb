# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/trading/brokers/broker_examples'

describe Jiji::Model::Trading::Brokers::BackTestBroker do
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:container) { Jiji::Test::TestContainerFactory.instance.new_container }
  let(:position_repository) do
    container.lookup(:position_repository)
  end
  let(:backtest_id) do
    backtest_repository  = container.lookup(:backtest_repository)
    registory            = container.lookup(:agent_registry)

    registory.add_source('aaa', '', :agent, data_builder.new_agent_body(1))

    test1 = data_builder.register_backtest(1, backtest_repository)
    test1.id
  end
  let(:broker) do
    Jiji::Model::Trading::Brokers::BackTestBroker.new(backtest_id,
      Time.utc(2015, 5, 1), Time.utc(2015, 5, 1, 0, 10),
      @pairs, 100_000, @repository)
  end

  before(:example) do
    @repository = Jiji::Model::Trading::TickRepository.new
    @securities_provider = Jiji::Model::Securities::SecuritiesProvider.new

    @repository.securities_provider = @securities_provider
    @securities_provider.set Jiji::Test::Mock::MockSecurities.new({})
    @pairs = [
      Jiji::Model::Trading::Pair.new(
        :EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
      Jiji::Model::Trading::Pair.new(
        :EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04),
      Jiji::Model::Trading::Pair.new(
        :USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
    ]
  end

  after(:example) do
    data_builder.clean
  end

  it_behaves_like 'brokerの基本操作ができる'

  it '期間内のレートを取得できる' do
    expect(broker.next?).to be true

    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 135.3
    expect(rates[:EURJPY].ask).to eq 135.33
    expect(rates[:EURUSD].bid).to eq 1.1234
    expect(rates[:EURUSD].ask).to eq 1.1236
    expect(rates.timestamp).to eq Time.utc(2015, 5, 1)

    expect(broker.next?).to be true

    broker.refresh
    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 135.56
    expect(rates[:EURJPY].ask).to eq 135.59
    expect(rates[:EURUSD].bid).to eq 1.3834
    expect(rates[:EURUSD].ask).to eq 1.3836
    expect(rates.timestamp).to eq Time.utc(2015, 5, 1, 0, 0, 15)

    38.times do |i|
      expect(broker.next?).to be true

      broker.refresh
      rates = broker.tick
      expect(rates[:EURJPY].bid).to be > 0
      expect(rates[:EURJPY].ask).to be > 0
      expect(rates[:USDJPY].bid).to be > 0
      expect(rates[:USDJPY].ask).to be > 0
      expect(rates.timestamp).to eq(Time.utc(2015, 5, 1, 0, 0, 30) + (i * 15))
    end

    expect(broker.next?).to be false
  end

  it 'start が end よりも未来の場合、エラーになる' do
    expect do
      Jiji::Model::Trading::Brokers::BackTestBroker.new(
        'test', Time.at(1000), Time.at(500), @pairs, @repository)
    end.to raise_error(ArgumentError)
  end
end
