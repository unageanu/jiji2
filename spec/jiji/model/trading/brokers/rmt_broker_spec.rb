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

  describe 'プラグインの変更' do
    let(:broker) do
      setting = @container.lookup(:setting_repository).securities_setting
      broker  = @container.lookup(:rmt_broker)

      setting.set_active_securities(:MOCK, {})
      broker
    end

    let(:pairs) do
      [
        Jiji::Model::Trading::Pair.new(
          :EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
        Jiji::Model::Trading::Pair.new(
          :EURUSD, 'EUR_USD', 0.0001, 10_000_000, 0.00001, 0.04),
        Jiji::Model::Trading::Pair.new(
          :USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
      ]
    end

    it 'プラグインが変更された場合、建玉と口座情報が更新される' do
      expect(broker.positions.length).to be 0
      expect(broker.account.profit_or_loss).to eq 0
      expect(broker.account.balance).to be 100_000

      mock = double('mock_broker')
      expect(mock).to receive(:retrieve_account)
        .and_return(Jiji::Model::Trading::Account.new(nil, 50_000, 0.04))
      expect(mock).to receive(:retrieve_trades)
        .and_return([
          data_builder.new_position(1),
          data_builder.new_position(2)
        ])
      expect(mock).to receive(:retrieve_current_tick)
        .and_return(data_builder.new_tick(2))
      expect(mock).to receive(:retrieve_pairs)
        .and_return(pairs)
      allow(mock).to receive(:close_trade)
        .and_return(
          Jiji::Model::Trading::ClosedPosition.new(
            '1', 10_000, 103, Time.at(200))
        )

      @provider.set mock

      expect(broker.positions.length).to be 2
      expect(broker.account.profit_or_loss).to eq(-10_090.0)
      expect(broker.account.margin_used).to eq 122_002.4
      expect(broker.account.balance).to be 50_000

      positions = position_repository.retrieve_positions(nil)
      expect(positions.length).to be 2
      expect(positions[0].internal_id).to eq '1'
      expect(positions[0].status).to eq :live
      expect(positions[0].entry_price).to eq 101.0
      expect(positions[0].current_price).to eq 102.003
      expect(positions[0].exit_price).to be nil
      expect(positions[1].internal_id).to eq '2'
      expect(positions[1].status).to eq :live
      expect(positions[1].entry_price).to eq 102.003
      expect(positions[1].current_price).to eq 102.0
      expect(positions[1].exit_price).to be nil

      broker.positions['1'].close
      positions = position_repository.retrieve_positions(nil)
      expect(positions.length).to be 2
      expect(positions[0].internal_id).to eq '1'
      expect(positions[0].status).to eq :closed
      expect(positions[0].entry_price).to eq 101.0
      expect(positions[0].current_price).to eq 103
      expect(positions[0].updated_at).to eq(Time.at(200))
      expect(positions[0].exit_price).to eq 103
      expect(positions[0].exited_at).to eq(Time.at(200))
      expect(positions[1].internal_id).to eq '2'
      expect(positions[1].status).to eq :live
      expect(positions[1].entry_price).to eq 102.003
      expect(positions[1].current_price).to eq 102.0
      expect(positions[1].exit_price).to be nil

      mock2 = double('mock_broker2')
      expect(mock2).to receive(:retrieve_account)
        .and_return(Jiji::Model::Trading::Account.new(nil, 60_000, 0.04))
      expect(mock2).to receive(:retrieve_trades)
        .and_return([
          data_builder.new_position(1),
          data_builder.new_position(3)
        ])
      expect(mock2).to receive(:retrieve_current_tick)
        .and_return(data_builder.new_tick(3))
      expect(mock2).to receive(:retrieve_pairs)
        .and_return(pairs)

      @provider.set mock2

      expect(broker.positions.length).to be 2
      expect(broker.account.profit_or_loss).to eq(-20_120.0)
      expect(broker.account.margin_used).to eq 164_000.0
      expect(broker.account.balance).to be 60_000

      positions = position_repository.retrieve_positions(nil)
      expect(positions.length).to be 4
      expect(positions[0].internal_id).to eq '1'
      expect(positions[0].status).to eq :closed
      expect(positions[0].entry_price).to eq 101.0
      expect(positions[0].current_price).to eq 103
      expect(positions[0].updated_at).to eq(Time.at(200))
      expect(positions[0].exit_price).to eq 103
      expect(positions[0].exited_at).to eq(Time.at(200))
      expect(positions[1].internal_id).to eq '1'
      expect(positions[1].status).to eq :live
      expect(positions[1].entry_price).to eq 101.0
      expect(positions[1].current_price).to eq 103.003
      expect(positions[1].exit_price).to be nil
      expect(positions[2].internal_id).to eq '2'
      expect(positions[2].status).to eq :lost
      expect(positions[2].entry_price).to eq 102.003
      expect(positions[2].current_price).to eq 102.0
      expect(positions[2].exit_price).to be nil
      expect(positions[3].internal_id).to eq '3'
      expect(positions[3].status).to eq :live
      expect(positions[3].entry_price).to eq 103
      expect(positions[3].current_price).to eq 103.003
      expect(positions[3].exit_price).to be nil
    end
  end
end
