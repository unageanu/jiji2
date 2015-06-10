# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/trading/brokers/broker_examples'

describe Jiji::Model::Trading::Brokers::RMTBroker do
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:position_repository) do
    @container.lookup(:position_repository)
  end
  let(:backtest_id) { nil }

  before(:example) do
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @provider     = @container.lookup(:securities_provider)
  end

  after(:example) do
    data_builder.clean
  end

  context 'プラグインが未設定の場合' do
    let(:broker) { @container.lookup(:rmt_broker) }

    before(:example) do
      @provider.set Jiji::Model::Securities::NilSecurities.new
    end

    it '売買はできない' do
      expect do
        broker.positions
      end.to raise_error(Errors::NotInitializedException)
      expect do
        broker.orders
      end.to raise_error(Errors::NotInitializedException)
      expect do
        broker.buy(:EURJPY, 1)
      end.to raise_error(Errors::NotInitializedException)
      expect do
        broker.sell(:USDJPY, 1, :limit, {
          price:  100,
          expiry: Time.utc(2015, 5, 1)
        })
      end.to raise_error(Errors::NotInitializedException)
    end

    it '破棄操作は可能' do
      broker.destroy
    end
  end

  context 'プラグインが設定されている場合' do
    before(:example) do
      @provider.get.reset
    end

    context 'プラグインをAPI呼び出しで設定した場合' do
      let(:broker) do
        setting = @container.lookup(:setting_repository).securities_setting
        broker  = @container.lookup(:rmt_broker)

        setting.set_active_securities(:MOCK, {})
        broker
      end

      it_behaves_like 'brokerの基本操作ができる'
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

      it_behaves_like 'brokerの基本操作ができる'
    end
  end
end
