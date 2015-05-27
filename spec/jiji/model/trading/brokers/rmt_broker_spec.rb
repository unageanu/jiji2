# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::Brokers::RMTBroker do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @provider     = @container.lookup(:securities_provider)
  end

  after(:example) do
    @data_builder.clean
  end

  context 'プラグインが未設定の場合' do
    let(:broker) { @container.lookup(:rmt_broker) }

    before(:example) do
      @provider.set nil
    end

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
        expect(pairs[1].name).to eq :EURUSD
        expect(pairs[2].name).to eq :USDJPY

        rates = broker.tick
        expect(rates[:EURJPY].bid).to eq 135.3
        expect(rates[:EURJPY].ask).to eq 135.33

        @provider.get.seed = 1
        rates = broker.tick
        expect(rates[:EURJPY].bid).to eq 135.3
        expect(rates[:EURJPY].ask).to eq 135.33

        broker.refresh
        rates = broker.tick
        expect(rates[:EURJPY].bid).to eq 136.3
        expect(rates[:EURJPY].ask).to eq 136.33
      end

      it '売買ができる' do
        broker.buy(:EURJPY, 1)
        broker.sell(:USDJPY, 2)
        broker.positions.each do |_k, v|
          broker.close(v._id)
        end
      end

      it '売買していても既定のレートを取得できる' do
        buy_position = broker.buy(:EURJPY, 10_000)
        expect(buy_position.profit_or_loss).to eq(-300)

        expect(broker.next?).to eq true
        expect(broker.tick[:EURJPY].bid).to eq 135.30

        @provider.get.seed += 0.26
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2300

        expect(broker.next?).to eq true
        expect(broker.tick[:EURJPY].bid).to eq 135.56

        sell_position = broker.sell(:EURUSD, 10_000)
        expect(sell_position.profit_or_loss).to eq(-2)

        broker.close(buy_position._id)

        @provider.get.seed += 0.04
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2300
        expect(sell_position.profit_or_loss).to eq(-402)

        @provider.get.seed += 0.003
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2300
        expect(sell_position.profit_or_loss).to eq(-432)

        @provider.get.seed -= 0.002
        broker.refresh

        expect(buy_position.profit_or_loss).to eq 2300
        expect(sell_position.profit_or_loss).to eq(-412)
      end

      it '破棄操作ができる' do
        broker.destroy
      end
    end

    context 'プラグインをAPI呼び出しで設定した場合' do
      let(:broker) do
        setting = @container.lookup(:setting_repository).securities_setting
        broker  = @container.lookup(:rmt_broker)

        setting.set_active_securities(:MOCK, {})
        broker
      end

      it_behaves_like 'プラグインが必要な操作ができる'
    end

    context '設定情報からプラグインを読み込んだ場合' do
      let(:broker) do
        setting = @container.lookup(:setting_repository).securities_setting
        setting.set_active_securities(:MOCK, {})

        # 永続化された設定から再構築する
        @container    = Jiji::Test::TestContainerFactory.instance.new_container
        @provider     = @container.lookup(:securities_provider)
        setting = @container.lookup(:setting_repository).securities_setting
        setting.setup
        broker = @container.lookup(:rmt_broker)
        broker
      end

      it_behaves_like 'プラグインが必要な操作ができる'
    end
  end
end
