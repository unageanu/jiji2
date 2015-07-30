# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::PositionRepository do
  include_context 'use backtests'
  let(:position_repository) { container.lookup(:position_repository) }
  let(:test1) { backtests[0] }
  let(:test2) { backtests[1] }
  let(:test3) { backtests[2] }
  before(:example) do
    register_rmt_positions
    register_backtest_positions(test1._id)
    register_backtest_positions(test2._id)
  end

  def register_rmt_positions
    register_positions(nil)
  end

  def register_backtest_positions(backtest_id)
    register_positions(backtest_id)
  end

  def register_positions(backtest_id)
    100.times do |i|
      position = data_builder.new_position(i, backtest_id)
      if i < 10
        position.update_state_to_lost
      elsif i < 50
        position.update_state_to_closed(
          position.current_price, Time.at(position.entered_at.to_i + 10))
      end
      position.save
    end
  end

  it 'ソート条件、取得数を指定して、一覧を取得できる' do
    positions = position_repository.retrieve_positions(nil)

    expect(positions.length).to eq(20)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(0))
    expect(positions[19].backtest_id).to eq(nil)
    expect(positions[19].entered_at).to eq(Time.at(19))

    positions = position_repository.retrieve_positions(
      nil, entered_at: :desc)

    expect(positions.size).to eq(20)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(99))
    expect(positions[19].backtest_id).to eq(nil)
    expect(positions[19].entered_at).to eq(Time.at(80))

    positions = position_repository.retrieve_positions(
      nil, { entered_at: :desc }, 10, 30)

    expect(positions.size).to eq(30)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(89))
    expect(positions[29].backtest_id).to eq(nil)
    expect(positions[29].entered_at).to eq(Time.at(60))

    positions = position_repository.retrieve_positions(
      nil, { entered_at: :asc }, 10, 30)

    expect(positions.size).to eq(30)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(10))
    expect(positions[29].backtest_id).to eq(nil)
    expect(positions[29].entered_at).to eq(Time.at(39))

    positions = position_repository.retrieve_positions(test1._id)

    expect(positions.size).to eq(20)
    expect(positions[0].backtest_id).to eq(test1._id)
    expect(positions[0].entered_at).to eq(Time.at(0))
    expect(positions[19].backtest_id).to eq(test1._id)
    expect(positions[19].entered_at).to eq(Time.at(19))

    positions = position_repository.retrieve_positions(
      test1._id, { exited_at: :desc }, 10, 30)

    expect(positions.size).to eq(30)
    expect(positions[0].backtest_id).to eq(test1._id)
    expect(positions[0].entered_at).to eq(Time.at(39))
    expect(positions[29].backtest_id).to eq(test1._id)
    expect(positions[29].entered_at).to eq(Time.at(10))

    positions = position_repository.retrieve_positions(test3._id)

    expect(positions.size).to eq(0)
  end

  it '検索条件を指定して、一覧を取得できる' do
    positions = position_repository.retrieve_positions(nil,
      { entered_at: :asc, id: :asc }, nil, nil, {
      :entered_at.gt => Time.at(30)
    })

    expect(positions.length).to eq(69)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(31))
    expect(positions[68].backtest_id).to eq(nil)
    expect(positions[68].entered_at).to eq(Time.at(99))
  end

  it '建玉の総数を取得できる' do
    count = position_repository.count_positions
    expect(count).to eq(100)

    count = position_repository.count_positions(test1._id)
    expect(count).to eq(100)

    count = position_repository.count_positions(nil, {
      :entered_at.gt => Time.at(30)
    })
    expect(count).to eq(69)
  end

  it '#retrieve_positions_within で期間内の建玉を取得できる' do
    positions = position_repository.retrieve_positions_within(
      nil, Time.at(8), Time.at(12))

    expect(positions.length).to eq(2)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(10))
    expect(positions[1].backtest_id).to eq(nil)
    expect(positions[1].entered_at).to eq(Time.at(11))

    positions = position_repository.retrieve_positions_within(
      nil, Time.at(30), Time.at(40))

    expect(positions.length).to eq(20)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(20))
    expect(positions[19].backtest_id).to eq(nil)
    expect(positions[19].entered_at).to eq(Time.at(39))

    positions = position_repository.retrieve_positions_within(
      nil, Time.at(55), Time.at(60))

    expect(positions.length).to eq(15)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(45))
    expect(positions[14].backtest_id).to eq(nil)
    expect(positions[14].entered_at).to eq(Time.at(59))

    positions = position_repository.retrieve_positions_within(
      nil, Time.at(90), Time.at(95))

    expect(positions.length).to eq(45)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(50))
    expect(positions[44].backtest_id).to eq(nil)
    expect(positions[44].entered_at).to eq(Time.at(94))

    positions = position_repository.retrieve_positions_within(
      test1._id, Time.at(55), Time.at(60))

    expect(positions.length).to eq(15)
    expect(positions[0].backtest_id).to eq(test1._id)
    expect(positions[0].entered_at).to eq(Time.at(45))
    expect(positions[14].backtest_id).to eq(test1._id)
    expect(positions[14].entered_at).to eq(Time.at(59))
  end

  it 'アクティブなRMTの建玉を取得できる' do
    positions = position_repository.retrieve_living_positions_of_rmt

    expect(positions.size).to eq(50)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(50))
    expect(positions[0].exited_at).to eq(nil)
    expect(positions[49].backtest_id).to eq(nil)
    expect(positions[49].entered_at).to eq(Time.at(99))
    expect(positions[49].exited_at).to eq(nil)
  end

  it '不要になったバックテストの建玉を削除できる' do
    positions = position_repository.retrieve_positions(test1._id)
    expect(positions.size).to eq(20)
    positions = position_repository.retrieve_positions(test2._id)
    expect(positions.size).to eq(20)

    position_repository.delete_all_positions_of_backtest(test1._id)

    positions = position_repository.retrieve_positions(test1._id)
    expect(positions.size).to eq(0)
    positions = position_repository.retrieve_positions(test2._id)
    expect(positions.size).to eq(20)
  end

  it '決済済みになったRMTの建玉を削除できる'  do
    positions = position_repository.retrieve_positions
    expect(positions.size).to eq(20)

    position_repository.delete_closed_positions_of_rmt(Time.at(40))

    positions = position_repository.retrieve_positions
    expect(positions.size).to eq(20)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(30))
    expect(positions[0].exited_at).to eq(Time.at(40))
    expect(positions[19].backtest_id).to eq(nil)
    expect(positions[19].entered_at).to eq(Time.at(49))
    expect(positions[19].exited_at).to eq(Time.at(59))

    position_repository.delete_closed_positions_of_rmt(Time.at(60))

    positions = position_repository.retrieve_positions
    expect(positions.size).to eq(20)
    expect(positions[0].backtest_id).to eq(nil)
    expect(positions[0].entered_at).to eq(Time.at(50))
    expect(positions[0].exited_at).to eq(nil)
    expect(positions[19].backtest_id).to eq(nil)
    expect(positions[19].entered_at).to eq(Time.at(69))
    expect(positions[19].exited_at).to eq(nil)
  end
end
