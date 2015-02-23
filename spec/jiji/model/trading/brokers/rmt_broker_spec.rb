# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Brokers::RMTBroker do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container

    @mock_plugin =  Jiji::Test::Mock::MockSecuritiesPlugin.instance
    @mock_plugin.seed = 0
  end

  after(:example) do
    @data_builder.clean
  end

  context 'プラグインが未設定の場合' do
    let(:broker) { @container.lookup(:rmt_broker) }

    it '売買はできない' do
      expect do
        broker.positions
      end.to raise_error(Errors::NotInitializedException)
      expect do
        broker.buy(:EURJPY, 1)
      end.to raise_error(Errors::NotInitializedException)
      expect do
        broker.positions
      end.to raise_error(Errors::NotInitializedException)
    end

    it '破棄操作は可能' do
      broker.destroy
    end
  end

  context 'プラグインが設定されている場合' do
    shared_examples 'プラグインが必要な操作ができる' do
      it 'rate,pairが取得できる' do
        pairs = broker.pairs
        expect(pairs.length).to eq 3
        expect(pairs[0].name).to eq :EURJPY
        expect(pairs[0].trade_unit).to eq 10_000
        expect(pairs[1].name).to eq :EURUSD
        expect(pairs[1].trade_unit).to eq 10_000
        expect(pairs[2].name).to eq :USDJPY
        expect(pairs[2].trade_unit).to eq 10_000

        rates = broker.tick
        expect(rates[:EURJPY].bid).to eq 145.000
        expect(rates[:EURJPY].ask).to eq 145.003
        expect(rates[:EURJPY].sell_swap).to eq 10
        expect(rates[:EURJPY].buy_swap).to eq(-20)

        @mock_plugin.seed = 1
        rates = broker.tick
        expect(rates[:EURJPY].bid).to eq 145.000
        expect(rates[:EURJPY].ask).to eq 145.003
        expect(rates[:EURJPY].sell_swap).to eq 10
        expect(rates[:EURJPY].buy_swap).to eq(-20)

        broker.refresh
        rates = broker.tick
        expect(rates[:EURJPY].bid).to eq 146.000
        expect(rates[:EURJPY].ask).to eq 146.003
        expect(rates[:EURJPY].sell_swap).to eq 10
        expect(rates[:EURJPY].buy_swap).to eq(-20)
      end

      it '売買ができる' do
        broker.buy(:EURJPY, 1)
        broker.sell(:USDJPY, 2)
        broker.positions.each do|_k, v|
          broker.close(v._id)
        end
      end

      it '売買していても既定のレートを取得できる' do
        buy_position = broker.buy(:EURJPY, 1)
        expect(buy_position.profit_or_loss).to eq(-30)

        expect(broker.next?).to eq true
        expect(broker.tick[:EURJPY].bid).to eq 145.00

        @mock_plugin.seed += 0.26
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2570

        expect(broker.next?).to eq true
        expect(broker.tick[:EURJPY].bid).to eq 145.26

        sell_position = broker.sell(:EURUSD, 2)
        expect(sell_position.profit_or_loss).to eq(-2)

        broker.close(buy_position._id)

        @mock_plugin.seed += 0.04
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2570
        expect(sell_position.profit_or_loss).to eq(-802)

        @mock_plugin.seed += 0.003
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2570
        expect(sell_position.profit_or_loss).to eq(-862)

        @mock_plugin.seed -= 0.002
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2570
        expect(sell_position.profit_or_loss).to eq(-822)
      end

      it '破棄操作ができる' do
        broker.destroy
      end
    end

    context 'プラグインをAPI呼び出しで設定した場合' do
      let(:broker) do
        setting = @container.lookup(:rmt_broker_setting)
        broker  = @container.lookup(:rmt_broker)

        setting.set_active_securities(:mock, {})
        broker
      end

      it_behaves_like 'プラグインが必要な操作ができる'
    end

    context '設定情報からプラグインを読み込んだ場合' do
      let(:broker) do
        setting = @container.lookup(:rmt_broker_setting)
        setting.set_active_securities(:mock, {})

        # 永続化された設定から再構築する
        @container    = Jiji::Test::TestContainerFactory.instance.new_container
        setting = @container.lookup(:rmt_broker_setting)
        setting.setup
        broker = @container.lookup(:rmt_broker)
        broker
      end

      it_behaves_like 'プラグインが必要な操作ができる'
    end
  end
end
