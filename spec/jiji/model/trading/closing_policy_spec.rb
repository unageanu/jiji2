# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::ClosingPolicy do
  describe '#should_close?' do
    it 'take_profitが設定されている場合、利益が設定値を上回った時点で決済される' do
      policy = Jiji::Model::Trading::ClosingPolicy.create({
        take_profit: 130
      })
      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 120
        p.current_price = 125
        p.sell_or_buy = :buy
        p.units = 1
      end

      expect(policy.should_close?(position)).to be false
      position.current_price = 130
      expect(policy.should_close?(position)).to be true
      position.current_price = 131
      expect(policy.should_close?(position)).to be true

      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 140
        p.current_price = 135
        p.sell_or_buy = :sell
        p.units = 1
      end

      expect(policy.should_close?(position)).to be false
      position.current_price = 130
      expect(policy.should_close?(position)).to be true
      position.current_price = 129
      expect(policy.should_close?(position)).to be true
    end

    it 'stop_lossが設定されている場合、損失が設定値を超えた時点で決済される' do
      policy = Jiji::Model::Trading::ClosingPolicy.create({
        stop_loss: 110
      })
      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 120
        p.current_price = 125
        p.sell_or_buy = :buy
        p.units = 1
      end

      expect(policy.should_close?(position)).to be false
      position.current_price = 110
      expect(policy.should_close?(position)).to be true
      position.current_price = 109
      expect(policy.should_close?(position)).to be true

      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 100
        p.current_price = 95
        p.sell_or_buy = :sell
        p.units = 1
      end

      expect(policy.should_close?(position)).to be false
      position.current_price = 110
      expect(policy.should_close?(position)).to be true
      position.current_price = 111
      expect(policy.should_close?(position)).to be true
    end

    it 'trailing_stopが設定されている場合、損失が値を超えた時点で決済される' do
      policy = Jiji::Model::Trading::ClosingPolicy.create({
        trailing_stop:   50,
        trailing_amount: 110
      })
      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 120
        p.current_price = 125
        p.sell_or_buy = :buy
        p.units = 1
      end

      expect(policy.should_close?(position)).to be false
      position.current_price = 110
      expect(policy.should_close?(position)).to be true
      position.current_price = 109
      expect(policy.should_close?(position)).to be true

      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 100
        p.current_price = 95
        p.sell_or_buy = :sell
        p.units = 1
      end

      expect(policy.should_close?(position)).to be false
      position.current_price = 110
      expect(policy.should_close?(position)).to be true
      position.current_price = 111
      expect(policy.should_close?(position)).to be true
    end
  end

  describe '#update_price' do
    it 'trailing_stopが設定されていれば、trailing_amountが更新される' do
      pair = Jiji::Model::Trading::Pair.new(
        :EURJPY, 'EUR_JPY', 0.01, 10_000_000, 0.001, 0.04)

      policy = Jiji::Model::Trading::ClosingPolicy.create({
        trailing_stop:   50,
        trailing_amount: 0
      })
      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 120
        p.current_price = 125
        p.sell_or_buy = :buy
        p.units = 1
      end

      policy.update_price(position, pair)
      expect(policy.trailing_amount).to eq 124.5
      position.current_price = 130
      policy.update_price(position, pair)
      expect(policy.trailing_amount).to eq 129.5
      position.current_price = 129.8
      policy.update_price(position, pair)
      expect(policy.trailing_amount).to eq 129.5

      policy = Jiji::Model::Trading::ClosingPolicy.create({
        trailing_stop:   50,
        trailing_amount: 0
      })
      position = Jiji::Model::Trading::Position.new do |p|
        p.entry_price = 140
        p.current_price = 135
        p.sell_or_buy = :sell
        p.units = 1
      end

      policy.update_price(position, pair)
      expect(policy.trailing_amount).to eq 135.5
      position.current_price = 130.1
      policy.update_price(position, pair)
      expect(policy.trailing_amount).to eq 130.6
      position.current_price = 130.4
      policy.update_price(position, pair)
      expect(policy.trailing_amount).to eq 130.6
    end
  end
end
