# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::TradingSummaries::TradingSummary do
  include_context 'use data_builder'
  let(:summary) { Jiji::Model::Trading::TradingSummaries::TradingSummary.new }
  let(:agent_sttings) do
    [
      data_builder.register_agent_setting('test1@var.rb'),
      data_builder.register_agent_setting('テスト2@var.rb')
    ]
  end

  describe '#add_position' do
    it '取引結果がない場合' do
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

    it '取引結果が1つの場合' do
      position1 = data_builder.new_position(1, nil, nil, :EURJPY)
      position1.update_state_to_closed(102, Time.at(100))

      summary.process_positions([
        position1
      ])
      expect(summary.to_h).to eq({
        states:          {
          count:  1,
          exited: 1
        },
        wins_and_losses: {
          win:  0,
          lose: 1,
          draw: 0
        },
        sell_or_buy:     { sell: 1, buy: 0 },
        pairs:           {
          EURJPY: 1
        },
        profit_or_loss:  {
          max_profit:           -10_000,
          max_loss:             -10_000,
          avg_profit:           0,
          avg_loss:             -10_000,
          total_profit:         0,
          total_loss:           -10_000,
          total_profit_or_loss: -10_000,
          profit_factor:        0
        },
        holding_period:  {
          max_period: 99,
          min_period: 99,
          avg_period: 99
        },
        units:           {
          max_units: 10_000,
          min_units: 10_000,
          avg_units: 10_000
        },
        agent_summary:   {
          '' => {
            name:            '',
            states:          {
              count:  1,
              exited: 1
            },
            wins_and_losses: {
              win:  0,
              lose: 1,
              draw: 0
            },
            sell_or_buy:     { sell: 1, buy: 0 },
            pairs:           {
              EURJPY: 1
            },
            profit_or_loss:  {
              max_profit:           -10_000,
              max_loss:             -10_000,
              avg_profit:           0,
              avg_loss:             -10_000,
              total_profit:         0,
              total_loss:           -10_000,
              total_profit_or_loss: -10_000,
              profit_factor:        0
            },
            holding_period:  {
              max_period: 99,
              min_period: 99,
              avg_period: 99
            },
            units:           {
              max_units: 10_000,
              min_units: 10_000,
              avg_units: 10_000
            }
          }
        }
      })
    end

    it '取引結果が複数の場合' do
      a1 = agent_sttings[0]
      a2 = agent_sttings[1]
      summary.process_positions([
        create_position(:EURJPY, :sell, 100,  99, 1000, a1, 100, 200), # 1000
        create_position(:EURJPY, :buy,  100,  99, 800, a1, 100, 300), # -800
        create_position(:USDJPY, :sell, 100,  99, 1400, a1, 100, 110), # 1400
        create_position(:USDJPY, :buy,  100,  99, 1200, a1, 100, 190), #-1200
        create_position(:EURJPY, :sell, 100, 100, 500, a1, 100, nil), #    0

        create_position(:EURJPY, :sell, 100,  99, 1000, a2, 100, 200), # 1000
        create_position(:EURJPY, :buy,  100,  99, 800, a2, 100, 300), # -800
        create_position(:USDJPY, :sell, 100,  99, 1400, a2, 100, 110), # 1400
        create_position(:USDJPY, :buy,  100,  99, 1200, a2, 100, 190), #-1200
        create_position(:EURJPY, :sell, 100, 100, 500, a2, 100, nil), #    0
      ])
      expect(summary.to_h).to eq({
        states:          {
          count:  10,
          exited: 8
        },
        wins_and_losses: {
          win:  4,
          lose: 4,
          draw: 2
        },
        sell_or_buy:     { sell: 6, buy: 4 },
        pairs:           {
          EURJPY: 6,
          USDJPY: 4
        },
        profit_or_loss:  {
          max_profit:           1400,
          max_loss:             -1200,
          avg_profit:           1200,
          avg_loss:             -1000,
          total_profit:         4800,
          total_loss:           -4000,
          total_profit_or_loss: 800,
          profit_factor:        1.2
        },
        holding_period:  {
          max_period: 200,
          min_period: 10,
          avg_period: 100
        },
        units:           {
          max_units: 1400,
          min_units: 500,
          avg_units: 980
        },
        agent_summary:   {
          agent_sttings[0].id => {
            name:            'test1@var.rb',
            states:          {
              count:  5,
              exited: 4
            },
            wins_and_losses: {
              win:  2,
              lose: 2,
              draw: 1
            },
            sell_or_buy:     { sell: 3, buy: 2 },
            pairs:           {
              EURJPY: 3,
              USDJPY: 2
            },
            profit_or_loss:  {
              max_profit:           1400,
              max_loss:             -1200,
              avg_profit:           1200,
              avg_loss:             -1000,
              total_profit:         2400,
              total_loss:           -2000,
              total_profit_or_loss: 400,
              profit_factor:        1.2
            },
            holding_period:  {
              max_period: 200,
              min_period: 10,
              avg_period: 100
            },
            units:           {
              max_units: 1400,
              min_units: 500,
              avg_units: 980
            }
          },
          agent_sttings[1].id => {
            name:            'テスト2@var.rb',
            states:          {
              count:  5,
              exited: 4
            },
            wins_and_losses: {
              win:  2,
              lose: 2,
              draw: 1
            },
            sell_or_buy:     { sell: 3, buy: 2 },
            pairs:           {
              EURJPY: 3,
              USDJPY: 2
            },
            profit_or_loss:  {
              max_profit:           1400,
              max_loss:             -1200,
              avg_profit:           1200,
              avg_loss:             -1000,
              total_profit:         2400,
              total_loss:           -2000,
              total_profit_or_loss: 400,
              profit_factor:        1.2
            },
            holding_period:  {
              max_period: 200,
              min_period: 10,
              avg_period: 100
            },
            units:           {
              max_units: 1400,
              min_units: 500,
              avg_units: 980
            }
          }
        }
      })
    end
  end

  def create_position(pair, sell_or_buy, entry_price, current_price,
    units = 1000, agent = nil, entered_at = 100, exited_at = 110)
    Jiji::Model::Trading::Position.new do |p|
      p.agent                = agent
      p.pair_name            = pair
      p.sell_or_buy          = sell_or_buy
      p.entry_price          = entry_price
      p.current_price        = current_price
      p.current_counter_rate = 1
      p.entered_at           = Time.at(entered_at)
      p.exited_at            = !exited_at.nil? ? Time.at(exited_at) : nil
      p.units                = units
      p.status               = !exited_at.nil? ? :closed : :live
    end
  end
end
