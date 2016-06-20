# coding: utf-8

RSpec.shared_examples '注文関連の操作(建玉がある場合のバリエーションパターン)' do
  describe 'Ordering' do
    let(:tick) { client.retrieve_current_tick }
    let(:now) { Time.now.round }

    before(:example) do
      @orders = []
    end

    after(:example) do
      client.retrieve_orders.each do |o|
        sleep wait
        begin
          client.cancel_order(o.internal_id)
        rescue
          p $ERROR_INFO
        end
      end
      sleep wait
      client.retrieve_trades.each do |t|
        sleep wait
        begin
          client.close_trade(t.internal_id)
        rescue
          p $ERROR_INFO
        end
      end
    end

    context '建玉がある場合' do
      before(:example) do
        client.retrieve_current_tick
        client.order(:EURJPY, :buy, 5)
      end

      it '逆方向の注文が約定すると、既存のポジジョンが削減される' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        positions = client.retrieve_trades

        sleep wait
        result = client.order(:EURJPY, :sell, 1)

        expect(result.order_opened).to be nil
        expect(result.trade_opened).to be nil
        expect(result.trade_reduced.internal_id).to eq(positions[0].internal_id)
        expect(result.trade_reduced.price).to be > 0
        expect(result.trade_reduced.units).to be 4
        expect(result.trade_reduced.profit_or_loss).to be nil
        expect(result.trade_reduced.timestamp).not_to be nil
        expect(result.trades_closed).to eq []

        sleep wait
        trades = client.retrieve_trades
        expect(trades.length).to be 1
        expect(trades[0].internal_id).to eq result.trade_reduced.internal_id
        expect(trades[0].units).to eq 4
        expect(trades[0].entry_price).to eq positions[0].entry_price

        sleep wait

        # 建玉より多く逆方向に取引
        # -> 建玉がすべて決済され、さらに追加で不足分の建玉が作成される
        result = client.order(:EURJPY, :sell, 5)

        expect(result.order_opened).to be nil
        expect(result.trade_opened.internal_id).not_to be nil
        expect(result.trade_opened.pair_name).to be :EURJPY
        expect(result.trade_opened.sell_or_buy).to be :sell
        expect(result.trade_opened.price).to be > 0
        expect(result.trade_opened.units).to be 1
        expect(result.trade_opened.type).to be :market
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed.length).to eq 1
        expect(result.trades_closed[0].internal_id).to eq(
          positions[0].internal_id)
        expect(result.trades_closed[0].price).to be > 0
        expect(result.trades_closed[0].profit_or_loss).to be nil
        expect(result.trades_closed[0].units).to be 4
        expect(result.trades_closed[0].timestamp).not_to be nil

        sleep wait
        positions = client.retrieve_trades
        expect(positions.length).to be 1
        expect(positions[0].internal_id).to eq result.trade_opened.internal_id
        expect(positions[0].units).to eq 1
        expect(positions[0].entry_price).to eq result.trade_opened.price

        sleep wait

        # 建玉と同数だけ、逆方向に取引
        # -> 建玉がすべて決済される
        result = client.order(:EURJPY, :buy, 1)

        expect(result.order_opened).to be nil
        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed.length).to eq 1
        expect(result.trades_closed[0].internal_id).to eq(
          positions[0].internal_id)
        expect(result.trades_closed[0].price).to be > 0
        expect(result.trades_closed[0].profit_or_loss).to be nil
        expect(result.trades_closed[0].units).to be 1
        expect(result.trades_closed[0].timestamp).not_to be nil

        sleep wait
        positions = client.retrieve_trades
        expect(positions.length).to be 0

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it '注文が同じ方向だと、別のポジジョンができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        positions0 = client.retrieve_trades

        sleep wait
        result = client.order(:EURJPY, :buy, 1)
        expect(result.order_opened).to be nil
        expect(result.trade_opened.internal_id).not_to be nil
        expect(result.trade_opened.price).to be > 0
        expect(result.trade_opened.pair_name).to be :EURJPY
        expect(result.trade_opened.sell_or_buy).to be :buy
        expect(result.trade_opened.units).to be 1
        expect(result.trade_opened.type).to be :market
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait
        positions = client.retrieve_trades
        expect(positions.length).to be 2
        expect(positions[0].internal_id).to eq result.trade_opened.internal_id
        expect(positions[0].units).to eq 1
        expect(positions[0].entry_price).to eq result.trade_opened.price
        expect(positions[1].internal_id).not_to be nil
        expect(positions[1].units).to eq 5
        expect(positions[1].entry_price).to eq positions0[0].entry_price

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it '複数の建玉があり、合計より大きな数で逆方向に取引すると、建玉がすべて決済される' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        sleep wait
        client.order(:EURJPY, :buy, 1)

        sleep wait
        positions = client.retrieve_trades
        expect(positions.length).to be 2

        result = client.order(:EURJPY, :sell, 6)
        expect(result.order_opened).to be nil
        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed.length).to eq 2
        expect(result.trades_closed[0].internal_id).to eq(
          positions[1].internal_id)
        expect(result.trades_closed[0].price).to be > 0
        expect(result.trades_closed[0].profit_or_loss).to be nil
        expect(result.trades_closed[0].units).to be 5
        expect(result.trades_closed[0].timestamp).not_to be nil
        expect(result.trades_closed[1].internal_id).to eq(
          positions[0].internal_id)
        expect(result.trades_closed[1].price).to be > 0
        expect(result.trades_closed[1].profit_or_loss).to be nil
        expect(result.trades_closed[1].units).to be 1
        expect(result.trades_closed[1].timestamp).not_to be nil

        sleep wait
        positions = client.retrieve_trades
        expect(positions.length).to be 0

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it '即時決済する条件で逆方向の指値注文が約定すると、既存のポジジョンが減る' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        bid = BigDecimal.new(tick[:EURJPY].bid, 4)

        sleep wait
        result = client.order(:EURJPY, :sell, 1, :limit, {
          price:  (bid - 1).to_f,
          expiry: now + (60 * 60 * 24)
        })
        expect(result.order_opened.internal_id).not_to be nil
        expect(result.order_opened.pair_name).to be :EURJPY
        expect(result.order_opened.sell_or_buy).to be :sell
        expect(result.order_opened.units).to be 1
        expect(result.order_opened.type).to be :limit
        expect(result.order_opened.price).to eq((bid - 1).to_f)
        expect(result.order_opened.expiry).to eq((now + (60 * 60 * 24)).utc)
        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait
        orders = client.retrieve_orders
        expect(orders.length).to be 0

        trades = client.retrieve_trades
        expect(trades.length).to be 1
        expect(trades[0].internal_id).not_to be nil
        expect(trades[0].units).to eq 4
        expect(trades[0].entry_price).not_to be nil

        sleep wait
        result = client.order(:EURJPY, :sell, 1, :stop, {
          price:  (bid + 1).to_f,
          expiry: now + (60 * 60 * 24)
        })
        expect(result.order_opened.internal_id).not_to be nil
        expect(result.order_opened.pair_name).to be :EURJPY
        expect(result.order_opened.sell_or_buy).to be :sell
        expect(result.order_opened.units).to be 1
        expect(result.order_opened.type).to be :stop
        expect(result.order_opened.price).to eq((bid + 1).to_f)
        expect(result.order_opened.expiry).to eq((now + (60 * 60 * 24)).utc)
        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait
        orders = client.retrieve_orders
        expect(orders.length).to be 0

        trades = client.retrieve_trades
        expect(trades.length).to be 1
        expect(trades[0].internal_id).not_to be nil
        expect(trades[0].units).to eq 3
        expect(trades[0].entry_price).not_to be nil

        # sleep wait
        # result = client.order(:EURJPY, :sell, 1, :marketIfTouched, {
        #   price:  (bid - 1).to_f,
        #   expiry: now + (60 * 60 * 24)
        # })
        # expect(result.order_opened.internal_id).not_to be nil
        # expect(result.order_opened.pair_name).to be :EURJPY
        # expect(result.order_opened.sell_or_buy).to be :sell
        # expect(result.order_opened.units).to be 1
        # expect(result.order_opened.type).to be :marketIfTouched
        # expect(result.order_opened.price).to eq((bid - 1).to_f)
        # expect(result.order_opened.expiry).to eq((now + (60 * 60 * 24)).utc)
        # expect(result.trade_opened).to be nil
        # expect(result.trade_reduced).to be nil
        # expect(result.trades_closed).to eq []
        #
        # sleep wait
        # orders = client.retrieve_orders
        # expect(orders.length).to be 0

        trades = client.retrieve_trades
        expect(trades.length).to be 1
        expect(trades[0].internal_id).not_to be nil
        expect(trades[0].units).to eq 3
        expect(trades[0].entry_price).not_to be nil

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end
    end
  end
end
