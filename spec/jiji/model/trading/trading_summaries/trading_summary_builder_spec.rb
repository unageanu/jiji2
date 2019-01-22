# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::TradingSummaries::TradingSummaryBuilder do
  include_context 'use backtests'
  let(:trading_summary_builder) { container.lookup(:trading_summary_builder) }
  let(:test) { backtests[0] }

  describe '#build' do
    it '取引結果がない場合もSummaryを構築できる' do
      summary = trading_summary_builder.build(nil)
      expect(summary.to_h).to eq({
        states:          { count: 0, exited: 0 },
        wins_and_losses: { win: 0, lose: 0, draw: 0 },
        sell_or_buy:     { sell: 0, buy: 0 },
        pairs:           {},
        profit_or_loss:  {
          max_profit:           nil,
          max_loss:             nil,
          avg_profit:           0,
          avg_loss:             0,
          total_profit:         0,
          total_loss:           0,
          total_profit_or_loss: 0,
          profit_factor:        0
        },
        holding_period:  {
          max_period: nil,
          min_period: nil,
          avg_period: 0
        },
        units:           {
          max_units: nil,
          min_units: nil,
          avg_units: 0
        },
        agent_summary:   {}
      })

      summary = trading_summary_builder.build(test._id)
      expect(summary.to_h).to eq({
        states:          { count: 0, exited: 0 },
        wins_and_losses: { win: 0, lose: 0, draw: 0 },
        sell_or_buy:     { sell: 0, buy: 0 },
        pairs:           {},
        profit_or_loss:  {
          max_profit:           nil,
          max_loss:             nil,
          avg_profit:           0,
          avg_loss:             0,
          total_profit:         0,
          total_loss:           0,
          total_profit_or_loss: 0,
          profit_factor:        0
        },
        holding_period:  {
          max_period: nil,
          min_period: nil,
          avg_period: 0
        },
        units:           {
          max_units: nil,
          min_units: nil,
          avg_units: 0
        },
        agent_summary:   {}
      })
    end

    it '取引結果を集計できる' do
      register_positions(10)

      summary = trading_summary_builder.build(nil).to_h
      expect(summary[:states][:count]).to eq(9)
      expect(summary[:states][:exited]).to eq(4)

      summary = trading_summary_builder.build(test._id).to_h
      expect(summary[:states][:count]).to eq(9)
      expect(summary[:states][:exited]).to eq(4)
    end

    it 'ページサイズを超える建玉が存在する場合、順次取得して集計できる' do
      register_positions(100)
      trading_summary_builder.page_size = 10

      summary = trading_summary_builder.build(nil).to_h
      expect(summary[:states][:count]).to eq(90)
      expect(summary[:states][:exited]).to eq(40)

      summary = trading_summary_builder.build(test._id).to_h
      expect(summary[:states][:count]).to eq(90)
      expect(summary[:states][:exited]).to eq(40)
    end

    it '期間が指定されている場合、その期間の建て玉の集計結果が返される' do
      register_positions(50)
      trading_summary_builder.page_size = 20

      summary = trading_summary_builder.build(nil, Time.at(10)).to_h
      expect(summary[:states][:count]).to eq(36)
      expect(summary[:states][:exited]).to eq(16)

      summary = trading_summary_builder.build(test._id,
        Time.at(10), Time.at(40)).to_h
      expect(summary[:states][:count]).to eq(27)
      expect(summary[:states][:exited]).to eq(12)

      summary = trading_summary_builder.build(nil, nil, Time.at(10)).to_h
      expect(summary[:states][:count]).to eq(9)
      expect(summary[:states][:exited]).to eq(4)
    end

    def register_positions(count)
      [test._id, nil].each do |backtest_id|
        count.times do |i|
          position = data_builder.new_position(i, backtest_id)
          if i % 10 == 0
            position.update_state_to_lost
          elsif i.even?
            position.update_state_to_closed(
              position.current_price, Time.at(position.entered_at.to_i + 10))
          end
          position.save
        end
      end
    end
  end
end
