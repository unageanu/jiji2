# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Brokers::BackTestBroker do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @data_builder.register_ticks(30, 60 * 10)
    @repository = Jiji::Model::Trading::TickRepository.new
  end

  after(:example) do
    @data_builder.clean
  end

  shared_examples 'broker の基本操作ができる' do
    it 'pair が取得できる' do
      pairs = broker.pairs
      expect(pairs.length).to be 3
      expect(pairs[0].name).to be :EURJPY
      expect(pairs[0].trade_unit).to be 10_000
      expect(pairs[1].name).to be :USDJPY
      expect(pairs[1].trade_unit).to be 10_000
      expect(pairs[2].name).to be :EURUSD
      expect(pairs[2].trade_unit).to be 10_000
    end

    it '売買ができる' do
      broker.buy(:EURJPY, 1)
      broker.sell(:USDJPY, 2)
      broker.positions.each do|_k, v|
        broker.close(v._id)
      end
    end

    it '破棄操作ができる' do
      broker.destroy
    end
  end

  context '全期間を対象に実行する場合' do
    let(:broker) do
      Jiji::Model::Trading::Brokers::BackTestBroker.new(
        'test', Time.at(0), Time.at(60 * 10 * 40), @repository)
    end

    it '期間内のレートを取得できる' do
      expect(broker.next?).to be true

      rates = broker.tick
      expect(rates[:EURJPY].bid).to eq 100
      expect(rates[:EURJPY].ask).to eq 100.003
      expect(rates[:EURJPY].buy_swap).to be 2
      expect(rates[:EURJPY].sell_swap).to be 20
      expect(rates[:EURUSD].bid).to eq 100
      expect(rates[:EURUSD].ask).to eq 100.003
      expect(rates[:EURUSD].buy_swap).to be 2
      expect(rates[:EURUSD].sell_swap).to be 20

      broker.refresh
      expect(broker.next?).to be true

      rates = broker.tick
      expect(rates[:EURJPY].bid).to eq 101
      expect(rates[:EURJPY].ask).to eq 101.003
      expect(rates[:EURJPY].buy_swap).to be 3
      expect(rates[:EURJPY].sell_swap).to be 21

      28.times do|_i|
        broker.refresh
        expect(broker.next?).to be true
        rates = broker.tick
        expect(rates[:EURJPY].bid).not_to be nil
        expect(rates[:EURJPY].ask).not_to be nil
        expect(rates[:USDJPY].bid).not_to be nil
        expect(rates[:USDJPY].ask).not_to be nil
      end

      broker.refresh
      expect(broker.next?).to be false
    end

    it '売買していても既定のレートを取得できる' do
      buy_position = broker.buy(:EURJPY, 1)
      expect(buy_position.profit_or_loss).to eq(-30)

      expect(broker.next?).to be true
      expect(broker.tick[:EURJPY].bid).to eq 100

      broker.refresh

      expect(buy_position.profit_or_loss).to eq 9970

      expect(broker.next?).to be true
      expect(broker.tick[:EURJPY].bid).to eq 101

      sell_position = broker.sell(:USDJPY, 2)
      expect(sell_position.profit_or_loss).to eq(-60)

      broker.close(buy_position._id)

      28.times do|_i|
        broker.refresh
        expect(broker.next?).to be true
        rates = broker.tick
        expect(rates[:EURJPY].bid).not_to be nil
        expect(rates[:EURJPY].ask).not_to be nil
        expect(rates[:USDJPY].bid).not_to be nil
        expect(rates[:USDJPY].ask).not_to be nil

        expect(buy_position.profit_or_loss).to eq 9970
        # expect( sell_position.profit_or_loss ).to eq -60 - (i+1) * 20000
      end

      broker.refresh
      expect(broker.next?).to be false
    end

    it 'refresh を行うまで同じレートが取得される' do
      expect(broker.next?).to be true

      rates = broker.tick
      expect(rates[:EURJPY].bid).to eq 100
      expect(rates[:EURJPY].ask).to eq 100.003
      expect(rates[:EURJPY].buy_swap).to be 2
      expect(rates[:EURJPY].sell_swap).to be 20
      expect(rates[:EURUSD].bid).to eq 100
      expect(rates[:EURUSD].ask).to eq 100.003
      expect(rates[:EURUSD].buy_swap).to be 2
      expect(rates[:EURUSD].sell_swap).to be 20

      rates = broker.tick
      expect(rates[:EURJPY].bid).to eq 100
      expect(rates[:EURJPY].ask).to eq 100.003
      expect(rates[:EURJPY].buy_swap).to be 2
      expect(rates[:EURJPY].sell_swap).to be 20
      expect(rates[:EURUSD].bid).to eq 100
      expect(rates[:EURUSD].ask).to eq 100.003
      expect(rates[:EURUSD].buy_swap).to be 2
      expect(rates[:EURUSD].sell_swap).to be 20
    end

    it_behaves_like 'broker の基本操作ができる'
  end

  context '期間の一部を対象に実行する場合' do
    let(:broker) do
      Jiji::Model::Trading::Brokers::BackTestBroker.new(
        'test', Time.at(100), Time.at(60 * 10 * 10 + 100), @repository)
    end

    it '期間内のレートを取得できる' do
      expect(broker.next?).to be true

      rates = broker.tick
      expect(rates[:EURJPY].bid).to eq 101
      expect(rates[:EURJPY].ask).to eq 101.003
      expect(rates[:EURJPY].buy_swap).to be 3
      expect(rates[:EURJPY].sell_swap).to be 21
      expect(rates[:EURUSD].bid).to eq 101
      expect(rates[:EURUSD].ask).to eq 101.003
      expect(rates[:EURUSD].buy_swap).to be 3
      expect(rates[:EURUSD].sell_swap).to be 21

      broker.refresh
      expect(broker.next?).to be true

      rates = broker.tick
      expect(rates[:EURJPY].bid).to eq 102
      expect(rates[:EURJPY].ask).to eq 102.003
      expect(rates[:EURJPY].buy_swap).to be 4
      expect(rates[:EURJPY].sell_swap).to be 22

      8.times do|_i|
        broker.refresh
        expect(broker.next?).to be true
        rates = broker.tick
        expect(rates[:EURJPY].bid).not_to be nil
        expect(rates[:EURJPY].ask).not_to be nil
        expect(rates[:USDJPY].bid).not_to be nil
        expect(rates[:USDJPY].ask).not_to be nil
      end

      broker.refresh
      expect(broker.next?).to be false
    end

    it_behaves_like 'broker の基本操作ができる'
  end

  context '期間内にTickがない場合' do
    let(:broker) do
      Jiji::Model::Trading::Brokers::BackTestBroker.new(
        'test', Time.at(20_000), Time.at(30_000), @repository)
    end

    it 'レートは取得できない' do
      expect(broker.next?).to be false
    end

    it 'pair は取得できない' do
      pairs = broker.pairs
      expect(pairs.length).to be 0
    end

    it '売買もできない' do
      expect do
        broker.buy(:EURJPY, 1)
      end.to raise_error(Jiji::Errors::IllegalStateException)
      expect do
        broker.sell(:USDJPY, 2)
      end.to raise_error(Jiji::Errors::IllegalStateException)
    end

    it '破棄操作ができる' do
      broker.destroy
    end
  end

  it 'start が end よりも未来の場合、エラーになる' do
    expect do
      Jiji::Model::Trading::Brokers::BackTestBroker.new(
        'test', Time.at(1000), Time.at(500), @repository)
    end.to raise_error(ArgumentError)
  end
end
