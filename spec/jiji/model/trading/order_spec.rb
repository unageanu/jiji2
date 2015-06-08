# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Order do
  describe '#carried_out?' do
    it '成行き注文の場合、常にtrue' do
      order = Jiji::Model::Trading::Order.new(:EURJPY, 1, :sell, :market, nil)

      expect(order.carried_out?(create_tick(100))).to be true
      expect(order.carried_out?(create_tick(101))).to be true
      expect(order.carried_out?(create_tick(99))).to be true
    end

    it '指値注文の場合、価格が既定値に達するとtrue' do
      order = Jiji::Model::Trading::Order.new(:EURJPY, 1, :sell, :limit, nil)
      order.price = 100

      expect(order.carried_out?(create_tick(100))).to be true
      expect(order.carried_out?(create_tick(101))).to be true
      expect(order.carried_out?(create_tick(99))).to be false

      order = Jiji::Model::Trading::Order.new(:EURJPY, 1, :buy, :limit, nil)
      order.price = 100.03

      expect(order.carried_out?(create_tick(100))).to be true
      expect(order.carried_out?(create_tick(101))).to be false
      expect(order.carried_out?(create_tick(99))).to be true
    end

    it '逆指値注文の場合、価格が既定値を下回るとtrue' do
      order = Jiji::Model::Trading::Order.new(:EURJPY, 1, :sell, :stop, nil)
      order.price = 100

      expect(order.carried_out?(create_tick(100))).to be true
      expect(order.carried_out?(create_tick(101))).to be false
      expect(order.carried_out?(create_tick(99))).to be true

      order = Jiji::Model::Trading::Order.new(:EURJPY, 1, :buy, :stop, nil)
      order.price = 100.03

      expect(order.carried_out?(create_tick(100))).to be true
      expect(order.carried_out?(create_tick(101))).to be true
      expect(order.carried_out?(create_tick(99))).to be false
    end

    it 'マーケットタッチの場合、価格が既定値に到達するとtrue' do
      order = Jiji::Model::Trading::Order.new(
        :EURJPY, 1, :sell, :marketIfTouched, nil)
      order.price = 100

      expect(order.carried_out?(create_tick(90))).to be false

      expect(order.carried_out?(create_tick(100))).to be true
      expect(order.carried_out?(create_tick(101))).to be true
      expect(order.carried_out?(create_tick(99))).to be false

      order = Jiji::Model::Trading::Order.new(
        :EURJPY, 1, :buy, :marketIfTouched, nil)
      order.price = 100.03

      expect(order.carried_out?(create_tick(110))).to be false

      expect(order.carried_out?(create_tick(100))).to be true
      expect(order.carried_out?(create_tick(101))).to be false
      expect(order.carried_out?(create_tick(99))).to be true
    end
  end

  def create_tick(price)
    Jiji::Model::Trading::Tick.new({
      EURJPY: Jiji::Model::Trading::Tick::Value.new(price, price + 0.03)
    }, Time.utc(2015, 5, 1, 0, 0, 0))
  end
end
