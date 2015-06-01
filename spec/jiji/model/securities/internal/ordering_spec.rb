# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

describe Jiji::Model::Securities::Internal::Ordering do
  let(:wait) { 1 }

  before(:example) do
    @client = Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  after(:example) do
  end

  describe 'orders' do
    let(:tick) { @client.retrieve_current_tick }
    let(:now) {  Time.now.round }

    before(:example) do
      @orders = []
    end

    after(:example) do
      @orders.each do |o|
        sleep wait
        begin
          @client.cancel_order(o.internal_id)
        rescue
          p $ERROR_INFO
        end
      end
      sleep wait
      @client.retrieve_trades.each do |t|
        sleep wait
        begin
          @client.close_trade(t.internal_id)
        rescue
          p $ERROR_INFO
        end
      end
    end

    it '成行で注文ができる' do
      bid = BigDecimal.new(tick[:USDJPY].bid, 4)

      order = @client.order(:EURJPY, :buy, 1)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 1
      expect(order.type).to be :market

      sleep wait

      order = @client.order(:USDJPY, :sell, 2, :market, {
        stop_loss:     (bid + 2).to_f,
        take_profit:   (bid - 2).to_f,
        trailing_stop: 5
      })
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :market
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 5

      sleep wait

      orders = @client.retrieve_orders
      expect(orders.length).to be 0
    end

    it '指値で注文ができる' do
      bid = BigDecimal.new(tick[:EURJPY].bid, 4)
      ask = BigDecimal.new(tick[:EURJPY].ask, 4)

      @orders <<  @client.order(:EURJPY, :buy, 1, :limit, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      order = @orders[0]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 1
      expect(order.type).to be :limit
      expect(order.price).to eq((ask - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

      sleep wait

      @orders <<  @client.order(:EURJPY, :sell, 2, :limit, {
        price:         (bid + 1).to_f,
        expiry:        now + (60 * 60 * 24),
        lower_bound:   (bid + 1.05).to_f,
        upper_bound:   (bid - 1.05).to_f,
        stop_loss:     (bid + 2).to_f,
        take_profit:   (bid - 2).to_f,
        trailing_stop: 5
      })
      order = @orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :limit
      expect(order.price).to eq((bid + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((bid + 1.05).to_f)
      expect(order.upper_bound).to eq((bid - 1.05).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 5

      sleep wait

      orders = @client.retrieve_orders
      expect(orders.length).to be 2
      order = orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 1
      expect(order.type).to be :limit
      expect(order.price).to eq((ask - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      order = orders[0]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :limit
      expect(order.price).to eq((bid + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((bid + 1.05).to_f)
      expect(order.upper_bound).to eq((bid - 1.05).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 5

      order = @client.retrieve_order_by_id(orders[1].internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 1
      expect(order.type).to be :limit
      expect(order.price).to eq((ask - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

      order = @client.retrieve_order_by_id(orders[0].internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :limit
      expect(order.price).to eq((bid + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((bid + 1.05).to_f)
      expect(order.upper_bound).to eq((bid - 1.05).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 5
    end

    it '逆指値で注文ができる' do
      bid = BigDecimal.new(tick[:USDJPY].bid, 4)
      ask = BigDecimal.new(tick[:USDJPY].ask, 4)

      @orders <<  @client.order(:USDJPY, :sell, 10, :stop, {
        price:  (bid - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      order = @orders[0]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 10
      expect(order.type).to be :stop
      expect(order.price).to eq((bid - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

      sleep wait

      @orders <<  @client.order(:USDJPY, :buy, 11, :stop, {
        price:         (ask + 1).to_f,
        expiry:        now + (60 * 60 * 24),
        lower_bound:   (ask + 1.05).to_f,
        upper_bound:   (ask + 0.95).to_f,
        stop_loss:     (ask - 2).to_f,
        take_profit:   (ask + 2).to_f,
        trailing_stop: 5
      })
      order = @orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 11
      expect(order.type).to be :stop
      expect(order.price).to eq((ask + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((ask + 1.05).to_f)
      expect(order.upper_bound).to eq((ask + 0.95).to_f)
      expect(order.stop_loss).to eq((ask - 2).to_f)
      expect(order.take_profit).to eq((ask + 2).to_f)
      expect(order.trailing_stop).to eq 5

      sleep wait

      orders = @client.retrieve_orders
      expect(orders.length).to be 2
      order = orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 10
      expect(order.type).to be :stop
      expect(order.price).to eq((bid - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      order = orders[0]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 11
      expect(order.type).to be :stop
      expect(order.price).to eq((ask + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((ask + 1.05).to_f)
      expect(order.upper_bound).to eq((ask + 0.95).to_f)
      expect(order.stop_loss).to eq((ask - 2).to_f)
      expect(order.take_profit).to eq((ask + 2).to_f)
      expect(order.trailing_stop).to eq 5

      order = @client.retrieve_order_by_id(orders[1].internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 10
      expect(order.type).to be :stop
      expect(order.price).to eq((bid - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

      order = @client.retrieve_order_by_id(orders[0].internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 11
      expect(order.type).to be :stop
      expect(order.price).to eq((ask + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((ask + 1.05).to_f)
      expect(order.upper_bound).to eq((ask + 0.95).to_f)
      expect(order.stop_loss).to eq((ask - 2).to_f)
      expect(order.take_profit).to eq((ask + 2).to_f)
      expect(order.trailing_stop).to eq 5
    end

    it 'Market If Touched　注文ができる' do
      bid = BigDecimal.new(tick[:EURJPY].bid, 4)
      ask = BigDecimal.new(tick[:EURJPY].ask, 4)

      @orders <<  @client.order(:EURJPY, :buy, 1, :marketIfTouched, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      order = @orders[0]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 1
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((ask - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

      sleep wait
      @orders <<  @client.order(:EURJPY, :sell, 2, :marketIfTouched, {
        price:         (bid + 1).to_f,
        expiry:        now + (60 * 60 * 24),
        lower_bound:   (bid + 0.95).to_f,
        upper_bound:   (bid + 1.05).to_f,
        stop_loss:     (bid + 2).to_f,
        take_profit:   (bid - 2).to_f,
        trailing_stop: 5
      })
      order = @orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((bid + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((bid + 0.95).to_f)
      expect(order.upper_bound).to eq((bid + 1.05).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 5

      sleep wait
      orders = @client.retrieve_orders
      expect(orders.length).to be 2
      order = orders[1]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 1
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((ask - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      order = orders[0]
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((bid + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((bid + 0.95).to_f)
      expect(order.upper_bound).to eq((bid + 1.05).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 5

      order = @client.retrieve_order_by_id(orders[1].internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 1
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((ask - 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

      order = @client.retrieve_order_by_id(orders[0].internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 2
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((bid + 1).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)
      expect(order.lower_bound).to eq((bid + 0.95).to_f)
      expect(order.upper_bound).to eq((bid + 1.05).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 5
    end

    it '指値注文を変更できる' do
      ask = BigDecimal.new(tick[:EURJPY].ask, 4)

      @orders <<  @client.order(:EURJPY, :buy, 1, :limit, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      order = @orders[0]

      sleep wait

      order = @client.modify_order(order.internal_id, {
        units:         2,
        price:         (ask - 1.5).to_f,
        expiry:        now + (60 * 60 * 20),
        lower_bound:   (ask - 1.55).to_f,
        upper_bound:   (ask - 1.45).to_f,
        stop_loss:     (ask - 2).to_f,
        take_profit:   (ask + 2).to_f,
        trailing_stop: 5
      })
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 2
      expect(order.type).to be :limit
      expect(order.price).to eq((ask - 1.5).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 20)).utc)
      expect(order.lower_bound).to eq((ask - 1.55).to_f)
      expect(order.upper_bound).to eq((ask - 1.45).to_f)
      expect(order.stop_loss).to eq((ask - 2).to_f)
      expect(order.take_profit).to eq((ask + 2).to_f)
      expect(order.trailing_stop).to eq 5

      sleep wait

      order = @client.retrieve_order_by_id(order.internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 2
      expect(order.type).to be :limit
      expect(order.price).to eq((ask - 1.5).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 20)).utc)
      expect(order.lower_bound).to eq((ask - 1.55).to_f)
      expect(order.upper_bound).to eq((ask - 1.45).to_f)
      expect(order.stop_loss).to eq((ask - 2).to_f)
      expect(order.take_profit).to eq((ask + 2).to_f)
      expect(order.trailing_stop).to eq 5
    end

    it '逆指値注文を変更できる' do
      bid = BigDecimal.new(tick[:USDJPY].bid, 4)

      @orders <<  @client.order(:USDJPY, :sell, 10, :stop, {
        price:  (bid - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      order = @orders[0]

      sleep wait

      order = @client.modify_order(order.internal_id, {
        units:         5,
        price:         (bid - 1.5).to_f,
        expiry:        now + (60 * 60 * 20),
        lower_bound:   (bid - 1.55).to_f,
        upper_bound:   (bid - 1.45).to_f,
        stop_loss:     (bid + 2).to_f,
        take_profit:   (bid - 2).to_f,
        trailing_stop: 6
      })
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 5
      expect(order.type).to be :stop
      expect(order.price).to eq((bid - 1.5).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 20)).utc)
      expect(order.lower_bound).to eq((bid - 1.55).to_f)
      expect(order.upper_bound).to eq((bid - 1.45).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 6

      sleep wait

      order = @client.retrieve_order_by_id(order.internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :USDJPY
      expect(order.sell_or_buy).to be :sell
      expect(order.units).to be 5
      expect(order.type).to be :stop
      expect(order.price).to eq((bid - 1.5).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 20)).utc)
      expect(order.lower_bound).to eq((bid - 1.55).to_f)
      expect(order.upper_bound).to eq((bid - 1.45).to_f)
      expect(order.stop_loss).to eq((bid + 2).to_f)
      expect(order.take_profit).to eq((bid - 2).to_f)
      expect(order.trailing_stop).to eq 6
    end

    it 'Market If Touched　注文を変更できる' do
      ask = BigDecimal.new(tick[:EURJPY].ask, 4)

      @orders <<  @client.order(:EURJPY, :buy, 1, :marketIfTouched, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      order = @orders[0]

      sleep wait
      order = @client.modify_order(order.internal_id, {
        units:         2,
        price:         (ask - 1.5).to_f,
        expiry:        now + (60 * 60 * 20),
        lower_bound:   (ask - 1.05).to_f,
        upper_bound:   (ask - 0.95).to_f,
        stop_loss:     (ask - 2).to_f,
        take_profit:   (ask + 2).to_f,
        trailing_stop: 5
      })
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 2
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((ask - 1.5).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 20)).utc)
      expect(order.lower_bound).to eq((ask - 1.05).to_f)
      expect(order.upper_bound).to eq((ask - 0.95).to_f)
      expect(order.stop_loss).to eq((ask - 2).to_f)
      expect(order.take_profit).to eq((ask + 2).to_f)
      expect(order.trailing_stop).to eq 5

      sleep wait
      order = @client.retrieve_order_by_id(order.internal_id)
      expect(order.internal_id).not_to be nil
      expect(order.pair_name).to be :EURJPY
      expect(order.sell_or_buy).to be :buy
      expect(order.units).to be 2
      expect(order.type).to be :marketIfTouched
      expect(order.price).to eq((ask - 1.5).to_f)
      expect(order.expiry).to eq((now + (60 * 60 * 20)).utc)
      expect(order.lower_bound).to eq((ask - 1.05).to_f)
      expect(order.upper_bound).to eq((ask - 0.95).to_f)
      expect(order.stop_loss).to eq((ask - 2).to_f)
      expect(order.take_profit).to eq((ask + 2).to_f)
      expect(order.trailing_stop).to eq 5
    end

    it '注文をキャンセルできる' do
      bid = BigDecimal.new(tick[:EURJPY].bid, 4)
      ask = BigDecimal.new(tick[:EURJPY].ask, 4)

      @orders <<  @client.order(:EURJPY, :buy, 1, :limit, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      sleep wait
      @orders <<  @client.order(:EURJPY, :sell, 10, :stop, {
        price:  (bid - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })
      sleep wait
      @orders <<  @client.order(:EURJPY, :buy, 1, :marketIfTouched, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      })

      sleep wait
      orders = @client.retrieve_orders
      expect(orders.length).to be 3

      orders.each do |o|
        sleep wait
        @client.cancel_order(o.internal_id)
      end

      sleep wait
      orders = @client.retrieve_orders
      expect(orders.length).to be 0

      @orders = []
    end
  end
end
