# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Positions do
  let(:container) do
    Jiji::Test::TestContainerFactory.instance.new_container
  end
  let(:builder)      { container.lookup(:position_builder) }
  let(:repository)   { container.lookup(:position_repository) }
  let(:data_builder) { Jiji::Test::DataBuilder.new }
  let(:original)  do
    [
      data_builder.new_position(1),
      data_builder.new_position(2),
      data_builder.new_position(3)
    ]
  end
  let(:account) do
    Jiji::Model::Trading::Account.new(nil, 1_000_000, 0.04)
  end
  let(:positions) do
    Jiji::Model::Trading::Positions.new(original, builder, account)
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

  before(:example) do
    original.each { |o| o.save }
    original[2].closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
      trailing_stop: 10
    })
  end

  after(:example) do
    data_builder.clean
  end

  describe '#update' do
    it '新しい建玉がある場合、一覧に追加される' do
      expect(account.profit_or_loss).to eq 0
      expect(account.margin_used).to eq 0

      new_positions = [
        data_builder.new_position(1),
        data_builder.new_position(2),
        data_builder.new_position(4),
        data_builder.new_position(3)
      ]
      positions.update(new_positions)

      expect(account.balance).to eq(1_000_000)
      expect(account.profit_or_loss).to eq(-300)
      expect(account.margin_used).to eq 412_007.2
      expect(account.updated_at).to eq nil

      expect(positions.length).to be 4
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.updated_at).to eq Time.at(1)

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.updated_at).to eq Time.at(2)

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.updated_at).to eq Time.at(3)

      position = positions['4']
      expect(position._id).to eq new_positions[2]._id
      expect(position.internal_id).to eq '4'
      expect(position.status).to eq :live
      expect(position.units).to be 40_000
      expect(position.updated_at).to eq Time.at(4)

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 4
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.updated_at).to eq Time.at(1)

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.updated_at).to eq Time.at(2)

      position = loaded[2]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.updated_at).to eq Time.at(3)

      position = loaded[3]
      expect(position._id).to eq new_positions[2]._id
      expect(position.internal_id).to eq '4'
      expect(position.status).to eq :live
      expect(position.units).to be 40_000
      expect(position.updated_at).to eq Time.at(4)
    end

    it '建玉の状態が更新されている場合、DBにも変更が反映される' do
      new_positions = [
        data_builder.new_position(1),
        data_builder.new_position(2),
        data_builder.new_position(3)
      ]
      new_positions[1].units = 10_000
      new_positions[1].pair_name = :EURUSD
      new_positions[1].updated_at = Time.at(100)

      positions.update(new_positions)

      expect(account.balance).to eq(1_000_000)
      expect(account.profit_or_loss).to eq(-150)
      expect(account.margin_used).to eq 204_801.2

      expect(positions.length).to be 3
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.updated_at).to eq Time.at(1)

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.updated_at).to eq Time.at(2)
      # update_at/current_priceは、update後にupdate_tickで更新するので、
      # 同期しない。

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.updated_at).to eq Time.at(3)

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 3
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.updated_at).to eq Time.at(1)

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.updated_at).to eq Time.at(2)

      position = loaded[2]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.updated_at).to eq Time.at(3)
    end

    it '建玉が削除された場合、約定状態にする' do
      positions.update_price(data_builder.new_tick(4, Time.at(100)), pairs)
      expect(account.balance).to eq(1_000_000)
      expect(account.profit_or_loss).to eq(-20_180)
      expect(account.margin_used).to eq 245_602.4
      expect(account.updated_at).to eq Time.at(100)

      new_positions = [
        data_builder.new_position(1),
        data_builder.new_position(3)
      ]
      positions.update(new_positions)
      expect(account.balance).to eq(1_039_940)
      expect(account.profit_or_loss).to eq(-60_120.0)
      expect(account.margin_used).to eq 164_000.0
      expect(account.updated_at).to eq Time.at(100)

      expect(positions.length).to be 2
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 104.003

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 104.003

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 3
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 104.003

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :closed
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq Time.at(100)
      expect(position.exit_price).to eq 104
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 104

      position = loaded[2]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 104.003
    end
  end

  describe '#update_price' do
    it 'すべての建玉の価格が更新される' do
      positions.update_price(data_builder.new_tick(4, Time.at(100)), pairs)

      expect(account.balance).to eq(1_000_000)
      expect(account.profit_or_loss).to eq(-20_180)
      expect(account.margin_used).to eq 245_602.4
      expect(account.updated_at).to eq Time.at(100)

      expect(positions.length).to be 3
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 104.003
      expect(position.closing_policy.trailing_stop).to eq 0
      expect(position.closing_policy.trailing_amount).to eq 0

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 104
      expect(position.closing_policy.trailing_stop).to eq 0
      expect(position.closing_policy.trailing_amount).to eq 0

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 104.003
      expect(position.closing_policy.trailing_stop).to eq 10
      expect(position.closing_policy.trailing_amount).to eq 104.103

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 3
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 104.003
      expect(position.closing_policy.trailing_stop).to eq 0
      expect(position.closing_policy.trailing_amount).to eq 0

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 104
      expect(position.closing_policy.trailing_stop).to eq 0
      expect(position.closing_policy.trailing_amount).to eq 0

      position = loaded[2]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 104.003
      expect(position.closing_policy.trailing_stop).to eq 10
      expect(position.closing_policy.trailing_amount).to eq 104.103
    end
  end

  describe '#apply_order_result' do
    it '新規に作成された取引がある場合、新しい建玉が作成され追加される' do
      order_result = data_builder.new_order_result(
        nil, data_builder.new_order(10))
      tick = data_builder.new_tick(4, Time.at(100))

      positions.apply_order_result(order_result, tick)

      expect(account.balance).to eq(1_000_000)
      expect(account.profit_or_loss).to eq(-600_180)
      expect(account.margin_used).to eq 685_602.4
      expect(account.updated_at).to eq Time.at(100)

      expect(positions.length).to be 4
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(1)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 101.003

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(2)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003

      position = positions['10']
      expect(position._id).not_to be nil
      expect(position.internal_id).to eq '10'
      expect(position.status).to eq :live
      expect(position.sell_or_buy).to eq :buy
      expect(position.pair_name).to eq :EURJPY
      expect(position.units).to be 100_000
      expect(position.entered_at).to eq Time.at(100)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 110
      expect(position.current_price).to eq 104

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 4
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(1)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 101.003

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(2)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = loaded[2]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003

      position = loaded[3]
      expect(position._id).not_to be nil
      expect(position.internal_id).to eq '10'
      expect(position.status).to eq :live
      expect(position.sell_or_buy).to eq :buy
      expect(position.pair_name).to eq :EURJPY
      expect(position.units).to be 100_000
      expect(position.entered_at).to eq Time.at(100)
      expect(position.updated_at).to eq Time.at(100)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 110
      expect(position.current_price).to eq 104
    end

    it '取引単位が減った建玉がある場合、建玉が分割されて一部だけ決済済み状態になる' do
      order_result = data_builder.new_order_result(
        nil, nil, data_builder.new_reduced_position(9, '2'))
      tick = data_builder.new_tick(4, Time.at(100))

      positions.apply_order_result(order_result, tick)

      expect(account.balance).to eq(1_076_967)
      expect(account.profit_or_loss).to eq(-147)
      expect(account.margin_used).to eq 200_721.08
      expect(account.updated_at).to eq Time.at(100)

      expect(positions.length).to be 3
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(1)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 101.003

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 9000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(9)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 4
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(1)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 101.003

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 9000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(9)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = loaded[2]
      expect(position._id).not_to be nil
      expect(position.internal_id).to eq '2_'
      expect(position.status).to eq :closed
      expect(position.units).to be 11_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(9)
      expect(position.exited_at).to eq Time.at(9)
      expect(position.exit_price).to eq 109
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 109

      position = loaded[3]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003
    end

    it '決済された建玉がある場合、決済済み状態になる' do
      order_result = data_builder.new_order_result(
        nil, nil, data_builder.new_reduced_position(9, '2'), [
          data_builder.new_closed_position(10, '1'),
          data_builder.new_closed_position(30, '3')
        ])
      tick = data_builder.new_tick(4, Time.at(100))

      positions.apply_order_result(order_result, tick)
      expect(account.balance).to eq(176_967.0)
      expect(account.profit_or_loss).to eq(-27)
      expect(account.margin_used).to eq 36_721.08
      expect(account.updated_at).to eq Time.at(100)

      expect(positions.length).to be 3
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :closed
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(10)
      expect(position.exited_at).to eq Time.at(10)
      expect(position.exit_price).to eq 110
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 110

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 9000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(9)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :closed
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(30)
      expect(position.exited_at).to eq Time.at(30)
      expect(position.exit_price).to eq 130
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 130

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 4
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :closed
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(10)
      expect(position.exited_at).to eq Time.at(10)
      expect(position.exit_price).to eq 110
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 110

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 9000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(9)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = loaded[2]
      expect(position._id).not_to be nil
      expect(position.internal_id).to eq '2_'
      expect(position.status).to eq :closed
      expect(position.units).to be 11_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(9)
      expect(position.exited_at).to eq Time.at(9)
      expect(position.exit_price).to eq 109
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 109

      position = loaded[3]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :closed
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(30)
      expect(position.exited_at).to eq Time.at(30)
      expect(position.exit_price).to eq 130
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 130
    end

    it '新規に注文が生成されただけの場合は、建玉は生成されない' do
      order_result = data_builder.new_order_result(
        data_builder.new_order(10))
      tick = data_builder.new_tick(4, Time.at(100))

      positions.apply_order_result(order_result, tick)
      expect(account.balance).to eq(1_000_000)
      expect(account.profit_or_loss).to eq(-180)
      expect(account.margin_used).to eq 245_602.4
      expect(account.updated_at).to eq Time.at(100)

      expect(positions.length).to be 3
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(1)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 101.003

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(2)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 3
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :live
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(1)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 101.003

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(2)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = loaded[2]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003
    end
  end

  describe '#apply_close_result' do
    it '決済された建玉がある場合、決済済み状態になる' do
      positions.apply_close_result(data_builder.new_closed_position(10, '1'))
      expect(account.balance).to eq(910_000)
      expect(account.profit_or_loss).to eq(-150)
      expect(account.margin_used).to eq 205_202.4
      expect(account.updated_at).to eq Time.at(10)

      expect(positions.length).to be 3
      position = positions['1']
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :closed
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(10)
      expect(position.exited_at).to eq Time.at(10)
      expect(position.exit_price).to eq 110
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 110

      position = positions['2']
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(2)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = positions['3']
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003

      loaded = repository.retrieve_positions
      expect(loaded.length).to be 3
      position = loaded[0]
      expect(position._id).to eq original[0]._id
      expect(position.internal_id).to eq '1'
      expect(position.status).to eq :closed
      expect(position.units).to be 10_000
      expect(position.entered_at).to eq Time.at(1)
      expect(position.updated_at).to eq Time.at(10)
      expect(position.exited_at).to eq Time.at(10)
      expect(position.exit_price).to eq 110
      expect(position.entry_price).to eq 101
      expect(position.current_price).to eq 110

      position = loaded[1]
      expect(position._id).to eq original[1]._id
      expect(position.internal_id).to eq '2'
      expect(position.status).to eq :live
      expect(position.units).to be 20_000
      expect(position.entered_at).to eq Time.at(2)
      expect(position.updated_at).to eq Time.at(2)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 102.003
      expect(position.current_price).to eq 102

      position = loaded[2]
      expect(position._id).to eq original[2]._id
      expect(position.internal_id).to eq '3'
      expect(position.status).to eq :live
      expect(position.units).to be 30_000
      expect(position.entered_at).to eq Time.at(3)
      expect(position.updated_at).to eq Time.at(3)
      expect(position.exited_at).to eq nil
      expect(position.exit_price).to eq nil
      expect(position.entry_price).to eq 103
      expect(position.current_price).to eq 103.003
    end
  end
end
