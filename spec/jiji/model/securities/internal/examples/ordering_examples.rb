# coding: utf-8

RSpec.shared_examples '注文関連の操作' do
  describe 'Ordering' do
    let(:tick) { client.retrieve_current_tick }
    let(:now) {  Time.now.round }
    let(:data_builder) { Jiji::Test::DataBuilder.new }

    before(:example) do
      @orders = []
      data_builder.cancel_all_orders_and_positions(client, wait)
    end

    after(:example) do
      data_builder.cancel_all_orders_and_positions(client, wait)
    end

    describe '成行注文' do
      let(:bid) { BigDecimal.new(tick[:USDJPY].bid, 4) }

      before(:example) do
        bid # orderの前に、client.retrieve_current_tickを呼び出しておく必要がある
      end

      it '成行で注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        order = client.order(:EURJPY, :buy, 1).trade_opened
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :market

        sleep wait

        order = client.order(:USDJPY, :sell, 2, :market, {
          stop_loss:     (bid + 2).to_f,
          take_profit:   (bid - 2).to_f,
          trailing_stop: 5
        }).trade_opened
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :USDJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 2
        expect(order.type).to be :market
        expect(order.stop_loss).to eq((bid + 2).to_f)
        expect(order.take_profit).to eq((bid - 2).to_f)
        expect(order.trailing_stop).to eq 5

        sleep wait

        orders = client.retrieve_orders
        expect(orders.length).to be 0

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 0, :market)
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :sell, -1, :market, {
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :unknown, 1, :market)
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :unknown, 1, :market, {
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end
    end

    describe '指値注文' do
      let(:bid) { BigDecimal.new(tick[:EURJPY].bid, 4) }
      let(:ask) { BigDecimal.new(tick[:EURJPY].ask, 4) }

      it '指値で注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        @orders <<  client.order(:EURJPY, :buy, 1, :limit, {
          price:  (ask - 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened
        order = @orders[0]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :limit
        expect(order.price).to eq((ask - 1).to_f)
        expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

        sleep wait

        @orders <<  client.order(:EURJPY, :sell, 2, :limit, {
          price:         (bid + 1).to_f,
          expiry:        now + (60 * 60 * 24),
          lower_bound:   (bid + 1.05).to_f,
          upper_bound:   (bid - 1.05).to_f,
          stop_loss:     (bid + 2).to_f,
          take_profit:   (bid - 2).to_f,
          trailing_stop: 5
        }).order_opened
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

        orders = client.retrieve_orders
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

        order = client.retrieve_order_by_id(orders[1].internal_id)
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :limit
        expect(order.price).to eq((ask - 1).to_f)
        expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

        order = client.retrieve_order_by_id(orders[0].internal_id)
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

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, -1, :limit, {
            price:  (ask - 1).to_f,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 0, :limit, {
            price:         (bid + 1).to_f,
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 1.05).to_f,
            upper_bound:   (bid - 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :unknown, 1, :limit, {
            price:  (ask - 1).to_f,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :unknown, 2, :limit, {
            price:         (bid + 1).to_f,
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 1.05).to_f,
            upper_bound:   (bid - 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 1.05).to_f,
            upper_bound:   (bid - 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:  -1,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:         {},
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 1.05).to_f,
            upper_bound:   (bid - 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が未指定の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:  (ask - 1).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:         (bid + 1).to_f,
            lower_bound:   (bid + 1.05).to_f,
            upper_bound:   (bid - 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:  (ask - 1).to_f,
            expiry: {}
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:         (bid + 1).to_f,
            expiry:        0,
            lower_bound:   (bid + 1.05).to_f,
            upper_bound:   (bid - 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:     (ask - 1).to_f,
            expiry:    now + (60 * 60 * 24),
            stop_loss: (ask + 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:     (bid + 1).to_f,
            expiry:    now + (60 * 60 * 24),
            stop_loss: (bid - 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:       (ask - 1).to_f,
            expiry:      now + (60 * 60 * 24),
            take_profit: (ask - 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:       (bid + 1).to_f,
            expiry:      now + (60 * 60 * 24),
            take_profit: (bid + 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)
      end
    end

    describe '逆指値注文' do
      let(:bid) { BigDecimal.new(tick[:USDJPY].bid, 4) }
      let(:ask) { BigDecimal.new(tick[:USDJPY].ask, 4) }

      it '逆指値で注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        @orders <<  client.order(:USDJPY, :sell, 10, :stop, {
          price:  (bid - 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened
        order = @orders[0]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :USDJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 10
        expect(order.type).to be :stop
        expect(order.price).to eq((bid - 1).to_f)
        expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

        sleep wait

        @orders <<  client.order(:USDJPY, :buy, 11, :stop, {
          price:         (ask + 1).to_f,
          expiry:        now + (60 * 60 * 24),
          lower_bound:   (ask + 1.05).to_f,
          upper_bound:   (ask + 0.95).to_f,
          stop_loss:     (ask - 2).to_f,
          take_profit:   (ask + 2).to_f,
          trailing_stop: 5
        }).order_opened
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

        orders = client.retrieve_orders
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

        order = client.retrieve_order_by_id(orders[1].internal_id)
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :USDJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 10
        expect(order.type).to be :stop
        expect(order.price).to eq((bid - 1).to_f)
        expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

        order = client.retrieve_order_by_id(orders[0].internal_id)
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

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 0, :stop, {
            price:  (bid - 1).to_f,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :buy, -1, :stop, {
            price:         (ask + 1).to_f,
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (ask + 1.05).to_f,
            upper_bound:   (ask + 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :unknown, 1, :stop, {
            price:  (bid - 1).to_f,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :unknown, 1, :stop, {
            price:         (ask + 1).to_f,
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (ask + 1.05).to_f,
            upper_bound:   (ask + 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :buy, -1, :stop, {
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (ask + 1.05).to_f,
            upper_bound:   (ask + 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            price:  0,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:         {},
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (ask + 1.05).to_f,
            upper_bound:   (ask + 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が未指定の場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            price:  (bid - 1).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:         (ask + 1).to_f,
            lower_bound:   (ask + 1.05).to_f,
            upper_bound:   (ask + 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が不正な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 10, :stop, {
            price:  (bid - 1).to_f,
            expiry: {}
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:         (ask + 1).to_f,
            expiry:        0,
            lower_bound:   (ask + 1.05).to_f,
            upper_bound:   (ask + 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:     (ask + 1).to_f,
            expiry:    now + (60 * 60 * 24),
            stop_loss: (ask + 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            price:     (bid + 1).to_f,
            expiry:    now + (60 * 60 * 24),
            stop_loss: (bid - 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:       (ask + 1).to_f,
            expiry:      now + (60 * 60 * 24),
            take_profit: (ask - 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            price:       (bid + 1).to_f,
            expiry:      now + (60 * 60 * 24),
            take_profit: (bid + 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)
      end
    end

    describe 'Market If Touched注文' do
      let(:bid) { BigDecimal.new(tick[:EURJPY].bid, 4) }
      let(:ask) { BigDecimal.new(tick[:EURJPY].ask, 4) }

      it 'Market If Touched 注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        @orders <<  client.order(:EURJPY, :buy, 1, :marketIfTouched, {
          price:  (ask - 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened
        order = @orders[0]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :marketIfTouched
        expect(order.price).to eq((ask - 1).to_f)
        expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

        sleep wait
        @orders <<  client.order(:EURJPY, :sell, 2, :marketIfTouched, {
          price:         (bid + 1).to_f,
          expiry:        now + (60 * 60 * 24),
          lower_bound:   (bid + 0.95).to_f,
          upper_bound:   (bid + 1.05).to_f,
          stop_loss:     (bid + 2).to_f,
          take_profit:   (bid - 2).to_f,
          trailing_stop: 5
        }).order_opened
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
        orders = client.retrieve_orders
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

        order = client.retrieve_order_by_id(orders[1].internal_id)
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :marketIfTouched
        expect(order.price).to eq((ask - 1).to_f)
        expect(order.expiry).to eq((now + (60 * 60 * 24)).utc)

        order = client.retrieve_order_by_id(orders[0].internal_id)
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

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, -1, :marketIfTouched, {
            price:  (ask - 1).to_f,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 0, :marketIfTouched, {
            price:         (bid + 1).to_f,
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 0.95).to_f,
            upper_bound:   (bid + 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :unknown, 1, :marketIfTouched, {
            price:  (ask - 1).to_f,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :unknown, 2, :marketIfTouched, {
            price:         (bid + 1).to_f,
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 0.95).to_f,
            upper_bound:   (bid + 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :marketIfTouched, {
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 0.95).to_f,
            upper_bound:   (bid + 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:  0,
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :marketIfTouched, {
            price:         {},
            expiry:        now + (60 * 60 * 24),
            lower_bound:   (bid + 0.95).to_f,
            upper_bound:   (bid + 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が未指定の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:  (ask - 1).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :marketIfTouched, {
            price:         (bid + 1).to_f,
            lower_bound:   (bid + 0.95).to_f,
            upper_bound:   (bid + 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:  (ask - 1).to_f,
            expiry: {}
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :marketIfTouched, {
            price:         (bid + 1).to_f,
            expiry:        0,
            lower_bound:   (bid + 0.95).to_f,
            upper_bound:   (bid + 1.05).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:     (ask - 1).to_f,
            expiry:    now + (60 * 60 * 24),
            stop_loss: (ask + 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 1, :marketIfTouched, {
            price:     (bid + 1).to_f,
            expiry:    now + (60 * 60 * 24),
            stop_loss: (bid - 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:       (ask - 1).to_f,
            expiry:      now + (60 * 60 * 24),
            take_profit: (ask - 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.order(:EURJPY, :sell, 1, :marketIfTouched, {
            price:       (bid + 1).to_f,
            expiry:      now + (60 * 60 * 24),
            take_profit: (bid + 2).to_f
          })
        end.to raise_exception(OandaAPI::RequestError)
      end
    end

    it '注文方法が不明な場合、エラーになる' do
      bid = BigDecimal.new(tick[:USDJPY].bid, 4)

      expect do
        client.order(:EURJPY, :buy, 0, :unknown)
      end.to raise_exception(OandaAPI::RequestError)

      expect do
        client.order(:USDJPY, :sell, -1, :unknown, {
          stop_loss:     (bid + 2).to_f,
          take_profit:   (bid - 2).to_f,
          trailing_stop: 5
        })
      end.to raise_exception(OandaAPI::RequestError)
    end

    describe '指値注文の変更' do
      let(:ask) { BigDecimal.new(tick[:EURJPY].ask, 4) }
      let(:bid) { BigDecimal.new(tick[:EURJPY].bid, 4) }

      before(:example) do
        @orders <<  client.order(:EURJPY, :buy, 1, :limit, {
          price:  (ask - 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened
        @orders <<  client.order(:EURJPY, :sell, 1, :limit, {
          price:  (bid + 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened

        sleep wait

        @buy_order  = @orders[0]
        @sell_order = @orders[1]
      end

      it '指値注文を変更できる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        order = client.modify_order(@buy_order.internal_id, {
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

        order = client.retrieve_order_by_id(order.internal_id)
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

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         0,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         -1,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         nil,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         -1,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         {},
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が未指定の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        nil,
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        {},
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        0,
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask + 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         (bid + 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid + 1.55).to_f,
            upper_bound:   (bid + 1.45).to_f,
            stop_loss:     (bid - 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         (bid + 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid + 1.55).to_f,
            upper_bound:   (bid + 1.45).to_f,
            stop_loss:     (bid - 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end
    end

    describe '逆指値注文の変更' do
      let(:ask) { BigDecimal.new(tick[:USDJPY].ask, 4) }
      let(:bid) { BigDecimal.new(tick[:USDJPY].bid, 4) }

      before(:example) do
        @orders <<  client.order(:USDJPY, :sell, 10, :stop, {
          price:  (bid - 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened
        @orders <<  client.order(:USDJPY, :buy, 1, :stop, {
          price:  (ask + 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened

        sleep wait

        @sell_order = @orders[0]
        @buy_order  = @orders[1]
      end

      it '逆指値注文を変更できる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        order = client.modify_order(@sell_order.internal_id, {
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

        order = client.retrieve_order_by_id(order.internal_id)
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

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         0,
            price:         (bid - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         -1,
            price:         (bid - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         nil,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         0,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         {},
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が未指定の場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         5,
            price:         (bid - 1.5).to_f,
            expiry:        nil,
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が不正な場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         5,
            price:         (bid - 1.5).to_f,
            expiry:        {},
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         5,
            price:         (bid - 1.5).to_f,
            expiry:        0,
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         5,
            price:         (bid - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid - 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         5,
            price:         (ask + 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask + 1.55).to_f,
            upper_bound:   (ask + 1.45).to_f,
            stop_loss:     (ask + 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         5,
            price:         (bid - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid - 1.55).to_f,
            upper_bound:   (bid - 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid + 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         5,
            price:         (ask + 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask + 1.55).to_f,
            upper_bound:   (ask + 1.45).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask - 2).to_f,
            trailing_stop: 6
          })
        end.to raise_exception(OandaAPI::RequestError)
      end
    end

    describe 'Market If Touched 注文の変更' do
      let(:ask) { BigDecimal.new(tick[:EURJPY].ask, 4) }
      let(:bid) { BigDecimal.new(tick[:EURJPY].bid, 4) }

      before(:example) do
        @orders << client.order(:EURJPY, :buy, 1, :marketIfTouched, {
          price:  (ask - 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened
        @orders << client.order(:EURJPY, :sell, 1, :marketIfTouched, {
          price:  (bid + 1).to_f,
          expiry: now + (60 * 60 * 24)
        }).order_opened

        sleep wait

        @buy_order  = @orders[0]
        @sell_order = @orders[1]
      end

      it 'Market If Touched 注文を変更できる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        order = client.modify_order(@buy_order.internal_id, {
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
        order = client.retrieve_order_by_id(order.internal_id)
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

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         -1,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         0,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         nil,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         0,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         {},
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が未指定の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        nil,
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it '有効期限が不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        {},
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        0,
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.55).to_f,
            upper_bound:   (ask - 1.45).to_f,
            stop_loss:     (ask + 2).to_f,
            take_profit:   (ask + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         (bid + 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid + 1.55).to_f,
            upper_bound:   (bid + 1.45).to_f,
            stop_loss:     (bid - 2).to_f,
            take_profit:   (bid - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         (ask - 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (ask - 1.05).to_f,
            upper_bound:   (ask - 0.95).to_f,
            stop_loss:     (ask - 2).to_f,
            take_profit:   (ask - 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         (bid + 1.5).to_f,
            expiry:        now + (60 * 60 * 20),
            lower_bound:   (bid + 1.55).to_f,
            upper_bound:   (bid + 1.45).to_f,
            stop_loss:     (bid + 2).to_f,
            take_profit:   (bid + 2).to_f,
            trailing_stop: 5
          })
        end.to raise_exception(OandaAPI::RequestError)
      end
    end

    it '注文をキャンセルできる' do
      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0

      bid = BigDecimal.new(tick[:EURJPY].bid, 4)
      ask = BigDecimal.new(tick[:EURJPY].ask, 4)

      client.order(:EURJPY, :buy, 1, :limit, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      }).order_opened
      sleep wait
      client.order(:EURJPY, :sell, 10, :stop, {
        price:  (bid - 1).to_f,
        expiry: now + (60 * 60 * 24)
      }).order_opened
      sleep wait
      client.order(:EURJPY, :buy, 1, :marketIfTouched, {
        price:  (ask - 1).to_f,
        expiry: now + (60 * 60 * 24)
      }).order_opened

      sleep wait
      orders = client.retrieve_orders
      expect(orders.length).to be 3

      orders.each do |o|
        sleep wait
        client.cancel_order(o.internal_id)
      end

      sleep wait
      orders = client.retrieve_orders
      expect(orders.length).to be 0

      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0
    end
  end
end
