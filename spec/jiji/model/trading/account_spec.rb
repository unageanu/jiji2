# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Account do
  include_context 'use data_builder'
  include_context 'use container'
  let(:builder)      { container.lookup(:position_builder) }
  let(:repository)   { container.lookup(:position_repository) }
  let(:positions) do
    Jiji::Model::Trading::Positions.new([
      data_builder.new_position(1),
      data_builder.new_position(2),
      data_builder.new_position(3)
    ], builder, Jiji::Model::Trading::Account.new(1, 'JPY', 10_000, 0.04))
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

  describe '+/-' do
    it '口座資産を増減できる' do
      account = Jiji::Model::Trading::Account.new(1, 'JPY', 10_000, 0.04)

      expect(account.balance).to be 10_000

      account += 100.33
      account += 100.03
      expect(account.balance).to eq 10_200.36

      account -= 50.17
      expect(account.balance).to eq 10_150.19
    end
  end
  describe 'update' do
    it '必要証拠金、合計損益が更新される' do
      account = Jiji::Model::Trading::Account.new(1, 'JPY', 10_000, 0.04)

      account.update(positions, Time.at(100))

      expect(account.margin_used).to eq 245_604.8
      expect(account.profit_or_loss).to eq(-180.0)
      expect(account.updated_at).to eq Time.at(100)

      tick = data_builder.new_tick(5, Time.at(200))
      positions.update_price(tick, pairs)
      account.update(positions, Time.at(200))

      expect(account.margin_used).to eq 252_004.8
      expect(account.profit_or_loss).to eq(-40_180.0)
      expect(account.updated_at).to eq Time.at(200)

      tick = data_builder.new_tick(6, Time.at(300))
      src = [
        data_builder.new_position(2),
        data_builder.new_position(4)
      ]
      positions.update(src)
      positions.update_price(tick, pairs)
      src[1].update_state_to_closed

      account.update(positions, Time.at(300))

      expect(account.margin_used.to_f).to eq(84_800.0)
      expect(account.profit_or_loss).to eq 79_940.0
      expect(account.updated_at).to eq Time.at(300)
    end
  end
end
