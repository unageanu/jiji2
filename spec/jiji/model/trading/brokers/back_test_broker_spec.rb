# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Brokers::BackTestBroker do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
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
    @data_builder.clean
  end

  let(:broker) do
    Jiji::Model::Trading::Brokers::BackTestBroker.new('test',
      Time.at(0), Time.at(15 * 30), @pairs, @repository)
  end

  it 'pair が取得できる' do
    pairs = broker.pairs
    expect(pairs.length).to be 3
    expect(pairs[0].name).to be :EURJPY
    expect(pairs[1].name).to be :EURUSD
    expect(pairs[2].name).to be :USDJPY
  end

  it '売買ができる' do
    broker.tick

    broker.buy(:EURJPY, 1)
    broker.sell(:USDJPY, 2)
    broker.positions.each do |v|
      broker.close_position(v)
    end
  end

  it '破棄操作ができる' do
    broker.destroy
  end

  it '期間内のレートを取得できる' do
    expect(broker.next?).to be true

    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 100
    expect(rates[:EURJPY].ask).to eq 100.003
    expect(rates[:EURUSD].bid).to eq 100
    expect(rates[:EURUSD].ask).to eq 100.003
    expect(rates.timestamp).to eq Time.at(0)

    expect(broker.next?).to be true

    broker.refresh
    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 101
    expect(rates[:EURJPY].ask).to eq 101.003
    expect(rates.timestamp).to eq Time.at(15)

    expect(broker.next?).to be true

    27.times do |i|
      broker.refresh
      rates = broker.tick
      expect(rates[:EURJPY].bid).not_to be nil
      expect(rates[:EURJPY].ask).not_to be nil
      expect(rates[:USDJPY].bid).not_to be nil
      expect(rates[:USDJPY].ask).not_to be nil
      expect(rates.timestamp).to eq Time.at(15 * (i + 2))

      expect(broker.next?).to be true
    end

    broker.refresh
    rates = broker.tick
    expect(rates.timestamp).to eq Time.at(15 * 29)
    expect(broker.next?).to be false
  end

  it '売買していても既定のレートを取得できる' do
    broker.tick

    result = broker.buy(:EURJPY, 10_000)
    buy_position = broker.positions[result.trade_opened.internal_id]
    expect(buy_position.profit_or_loss).to eq(-30)

    expect(broker.next?).to be true
    expect(broker.tick[:EURJPY].bid).to eq 100

    broker.refresh

    expect(buy_position.profit_or_loss).to eq 9970

    expect(broker.next?).to be true
    expect(broker.tick[:EURJPY].bid).to eq 101

    result = broker.sell(:USDJPY, 20_000)
    sell_position = broker.positions[result.trade_opened.internal_id]
    expect(sell_position.profit_or_loss).to eq(-60)

    broker.close_position(buy_position)

    27.times do |_i|
      broker.refresh
      rates = broker.tick
      expect(broker.next?).to be true
      expect(rates[:EURJPY].bid).not_to be nil
      expect(rates[:EURJPY].ask).not_to be nil
      expect(rates[:USDJPY].bid).not_to be nil
      expect(rates[:USDJPY].ask).not_to be nil

      expect(buy_position.profit_or_loss).to eq 9970
      # expect( sell_position.profit_or_loss ).to eq -60 - (i+1) * 20000
    end

    broker.refresh
    broker.tick
    expect(broker.next?).to be false
  end

  it 'refresh を行うまで同じレートが取得される' do
    expect(broker.next?).to be true

    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 100
    expect(rates[:EURJPY].ask).to eq 100.003
    expect(rates[:EURUSD].bid).to eq 100
    expect(rates[:EURUSD].ask).to eq 100.003

    rates = broker.tick
    expect(rates[:EURJPY].bid).to eq 100
    expect(rates[:EURJPY].ask).to eq 100.003
    expect(rates[:EURUSD].bid).to eq 100
    expect(rates[:EURUSD].ask).to eq 100.003
  end

  it 'start が end よりも未来の場合、エラーになる' do
    expect do
      Jiji::Model::Trading::Brokers::BackTestBroker.new(
        'test', Time.at(1000), Time.at(500), @pairs, @repository)
    end.to raise_error(ArgumentError)
  end
end
