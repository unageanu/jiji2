# frozen_string_literal: true

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
      let(:bid) { BigDecimal(tick[:USDJPY].bid, 10) }

      before(:example) do
        bid # orderの前に、client.retrieve_current_tickを呼び出しておく必要がある
      end

      it '成行で注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        result = client.order(:EURJPY, :buy, 1)
        order = result.order_opened
        expect(order).to be nil

        trade = result.trade_opened
        expect(trade.internal_id).not_to be nil
        expect(trade.pair_name).to be :EURJPY
        expect(trade.sell_or_buy).to be :buy
        expect(trade.units).to be 1
        expect(trade.status).to be :live
        expect(trade.profit_or_loss).not_to be nil
        expect(trade.max_drow_down).not_to be nil
        expect(trade.entry_price).not_to be nil
        expect(trade.current_price).not_to be nil
        expect(trade.exit_price).to be nil
        expect(trade.entered_at.class).to eq Time
        expect(trade.exited_at).to be nil
        expect(trade.updated_at.class).to eq Time
        expect(trade.closing_policy.take_profit).to eq 0
        expect(trade.closing_policy.stop_loss).to eq 0
        expect(trade.closing_policy.trailing_stop).to eq 0

        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        trades = client.retrieve_trades
        trade = trades.find { |t| t.internal_id == trade.internal_id }
        expect(trade).not_to be nil
        expect(trade.internal_id).not_to be nil
        expect(trade.pair_name).to be :EURJPY
        expect(trade.sell_or_buy).to be :buy
        expect(trade.units).to be 1
        expect(trade.status).to be :live
        expect(trade.profit_or_loss).not_to be nil
        expect(trade.max_drow_down).not_to be nil
        expect(trade.entry_price).not_to be nil
        expect(trade.current_price).not_to be nil
        expect(trade.exit_price).to be nil
        expect(trade.entered_at.class).to eq Time
        expect(trade.exited_at).to be nil
        expect(trade.updated_at.class).to eq Time
        expect(trade.closing_policy.take_profit).to eq 0
        expect(trade.closing_policy.stop_loss).to eq 0
        expect(trade.closing_policy.trailing_stop).to eq 0

        sleep wait

        result = client.order(:USDJPY, :sell, 2, :market, {
          price_bound: bid - 0.1,
          time_in_force: "IOC",
          positionFill: "OPEN_ONLY",
          client_extensions: {
            id: "clientId",
            tag: "clientTag",
            comment: "clientComment"
          },
          take_profit_on_fill: {
            price: bid - 2,
            time_in_force: "GTD",
            gtd_time: now + (60 * 60 * 24)
          },
          stop_loss_on_fill: {
            distance: 100,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId2",
              tag: "clientTag",
              comment: "clientComment"
            },
          },
          trailing_stop_loss_on_fill: {
            distance: 20,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId3",
              tag: "clientTag",
              comment: "clientComment"
            }
          },
          trade_client_extensions: {
            id: "tradeClientId",
            tag: "tradeClientTag",
            comment: "tradeClientComment"
          }
        })
        order = result.order_opened
        expect(order).to be nil

        trade = result.trade_opened
        expect(trade.internal_id).not_to be nil
        expect(trade.pair_name).to be :USDJPY
        expect(trade.sell_or_buy).to be :sell
        expect(trade.units).to be 2
        expect(trade.status).to be :live
        expect(trade.profit_or_loss).not_to be nil
        expect(trade.max_drow_down).not_to be nil
        expect(trade.entry_price).not_to be nil
        expect(trade.current_price).not_to be nil
        expect(trade.exit_price).to be nil
        expect(trade.entered_at.class).to eq Time
        expect(trade.exited_at).to be nil
        expect(trade.updated_at.class).to eq Time
        expect(trade.closing_policy.take_profit).to eq(bid - 2)
        expect(trade.closing_policy.stop_loss).to eq(BigDecimal(trade.entry_price, 10) + 100)
        expect(trade.closing_policy.trailing_stop).to eq(20)

        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        trades = client.retrieve_trades
        trade = trades.find { |t| t.internal_id == trade.internal_id }
        expect(trade).not_to be nil
        expect(trade.internal_id).not_to be nil
        expect(trade.pair_name).to be :USDJPY
        expect(trade.sell_or_buy).to be :sell
        expect(trade.units).to be 2
        expect(trade.status).to be :live
        expect(trade.profit_or_loss).not_to be nil
        expect(trade.max_drow_down).not_to be nil
        expect(trade.entry_price).not_to be nil
        expect(trade.current_price).not_to be nil
        expect(trade.exit_price).to be nil
        expect(trade.entered_at.class).to eq Time
        expect(trade.exited_at).to be nil
        expect(trade.updated_at.class).to eq Time
        expect(trade.closing_policy.take_profit).to eq(bid - 2)
        expect(trade.closing_policy.stop_loss).to eq(BigDecimal(trade.entry_price, 10) + 100)
        expect(trade.closing_policy.trailing_stop).to eq(20)

        sleep wait

        orders = client.retrieve_orders
        expect(orders.length).to be 0

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 0, :market)
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:USDJPY, :sell, -1, :market, {
            time_in_force: "IOC",
            positionFill: "OPEN_ONLY",
            client_extensions: {
              id: "clientId",
              tag: "clientTag",
              comment: "clientComment"
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :unknown, 1, :market)
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:USDJPY, :unknown, 1, :market, {
            time_in_force: "IOC",
            positionFill: "OPEN_ONLY",
            client_extensions: {
              id: "clientId",
              tag: "clientTag",
              comment: "clientComment"
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end
    end

    describe '指値注文' do
      let(:bid) { BigDecimal(tick[:EURJPY].bid, 10) }
      let(:ask) { BigDecimal(tick[:EURJPY].ask, 10) }

      it '指値で注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        result = client.order(:EURJPY, :buy, 1, :limit, {
          price:  ask - 1
        })
        @orders << result.order_opened
        order = @orders[0]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :limit
        expect(order.price).to eq(ask - 1)
        expect(order.time_in_force).to eq "GTC"
        expect(order.gtd_time).to eq nil
        expect(order.price_bound).to be nil
        expect(order.position_fill).to eq "DEFAULT"
        expect(order.trigger_condition).to eq "DEFAULT"
        expect(order.client_extensions).to be nil
        expect(order.take_profit_on_fill).to be nil
        expect(order.stop_loss_on_fill).to be nil

        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait

        result = client.order(:EURJPY, :sell, 2, :limit, {
          price:         bid + 1,
          time_in_force: 'GTD',
          gtd_time: now + (60 * 60 * 24),
          position_fill: "REDUCE_FIRST",
          trigger_condition: "BID",
          client_extensions: {
            id: "clientId",
            tag: "clientTag",
            comment: "clientComment"
          },
          take_profit_on_fill: {
            price: bid - 2,
            time_in_force: "GTD",
            gtd_time: now + (60 * 60 * 24)
          },
          stop_loss_on_fill: {
            price: bid + 2,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId2",
              tag: "clientTag",
              comment: "clientComment"
            },
          },
          trailing_stop_loss_on_fill: {
            distance: 5,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId3",
              tag: "clientTag",
              comment: "clientComment"
            }
          },
          trade_client_extensions: {
            id: "tradeClientId",
            tag: "tradeClientTag",
            comment: "tradeClientComment"
          }
        })
        @orders << result.order_opened
        order = @orders[1]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 2
        expect(order.type).to be :limit
        expect(order.price).to eq(bid + 1)
        expect(order.time_in_force).to eq "GTD"
        expect(order.gtd_time).to eq  now + (60 * 60 * 24)
        expect(order.price_bound).to eq nil
        expect(order.position_fill).to eq "REDUCE_FIRST"
        expect(order.trigger_condition).to eq "BID"
        expect(order.client_extensions).to eq({
          id: "clientId",
          tag: "clientTag",
          comment: "clientComment"
        })
        expect(order.take_profit_on_fill).to eq({
          price: bid - 2,
          time_in_force: "GTD",
          gtd_time: now + (60 * 60 * 24)
        })
        expect(order.stop_loss_on_fill).to eq({
          price: bid + 2,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId2",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trailing_stop_loss_on_fill).to eq({
          distance: 5,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId3",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trade_client_extensions).to eq({
          id: "tradeClientId",
          tag: "tradeClientTag",
          comment: "tradeClientComment"
        })

        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait

        orders = client.retrieve_orders
        expect(orders.length).to be 2
        expect(orders[1]).to eq @orders[0]
        expect(orders[0]).to eq @orders[1]

        expect(client.retrieve_order_by_id(@orders[0].internal_id)).to eq @orders[0]
        expect(client.retrieve_order_by_id(@orders[1].internal_id)).to eq @orders[1]

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, -1, :limit, {
            price:  ask - 1
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 0, :limit, {
            price:         bid + 1,
            time_in_force: 'GTD',
            gtd_time: now + (60 * 60 * 24),
            position_fill: "REDUCE_FIRST",
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :unknown, 1, :limit, {
            price:  ask - 1
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :unknown, 2, :limit, {
            price:         bid + 1,
            time_in_force: 'GTD',
            gtd_time: now + (60 * 60 * 24),
            position_fill: "REDUCE_FIRST",
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            expiry: now + (60 * 60 * 24)
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            time_in_force: 'GTD',
            gtd_time: now + (60 * 60 * 24),
            position_fill: "REDUCE_FIRST",
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:  -1
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:         {},
            time_in_force: 'GTD',
            gtd_time: now + (60 * 60 * 24),
            position_fill: "REDUCE_FIRST",
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:     ask - 1,
            stop_loss_on_fill: {
              price: ask + 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:     bid + 1,
            stop_loss_on_fill: {
              price: bid - 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :limit, {
            price:       ask - 1,
            take_profit_on_fill: {
              price: ask - 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :limit, {
            price:       bid + 1,
            take_profit_on_fill: {
              price: bid + 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end
    end

    describe '逆指値注文' do
      let(:bid) { BigDecimal(tick[:USDJPY].bid, 10) }
      let(:ask) { BigDecimal(tick[:USDJPY].ask, 10) }

      it '逆指値で注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        result = client.order(:USDJPY, :sell, 10, :stop, {
          price:  bid - 1
        })
        @orders << result.order_opened
        order = @orders[0]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :USDJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 10
        expect(order.type).to be :stop
        expect(order.price).to eq(bid - 1)
        expect(order.time_in_force).to eq "GTC"
        expect(order.gtd_time).to eq nil
        expect(order.price_bound).to be nil
        expect(order.position_fill).to eq "DEFAULT"
        expect(order.trigger_condition).to eq "DEFAULT"
        expect(order.client_extensions).to be nil
        expect(order.take_profit_on_fill).to be nil
        expect(order.stop_loss_on_fill).to be nil

        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait

        result = client.order(:USDJPY, :buy, 11, :stop, {
          price:         ask + 1,
          price_bound:   ask + 1.05,
          time_in_force: 'GTD',
          gtd_time: now + (60 * 60 * 24),
          position_fill: "REDUCE_FIRST",
          trigger_condition: "BID",
          client_extensions: {
            id: "clientId",
            tag: "clientTag",
            comment: "clientComment"
          },
          take_profit_on_fill: {
            price: ask + 2,
            time_in_force: "GTD",
            gtd_time: now + (60 * 60 * 24)
          },
          stop_loss_on_fill: {
            price: ask - 2,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId2",
              tag: "clientTag",
              comment: "clientComment"
            },
          },
          trailing_stop_loss_on_fill: {
            distance: 5,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId3",
              tag: "clientTag",
              comment: "clientComment"
            }
          },
          trade_client_extensions: {
            id: "tradeClientId",
            tag: "tradeClientTag",
            comment: "tradeClientComment"
          }
        })
        @orders << result.order_opened
        order = @orders[1]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :USDJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 11
        expect(order.type).to be :stop
        expect(order.price).to eq(ask + 1)
        expect(order.time_in_force).to eq "GTD"
        expect(order.gtd_time).to eq  now + (60 * 60 * 24)
        expect(order.price_bound).to eq ask + 1.05
        expect(order.position_fill).to eq "REDUCE_FIRST"
        expect(order.trigger_condition).to eq "BID"
        expect(order.client_extensions).to eq({
          id: "clientId",
          tag: "clientTag",
          comment: "clientComment"
        })
        expect(order.take_profit_on_fill).to eq({
          price: ask + 2,
          time_in_force: "GTD",
          gtd_time: now + (60 * 60 * 24)
        })
        expect(order.stop_loss_on_fill).to eq({
          price: ask - 2,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId2",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trailing_stop_loss_on_fill).to eq({
          distance: 5,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId3",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trade_client_extensions).to eq({
          id: "tradeClientId",
          tag: "tradeClientTag",
          comment: "tradeClientComment"
        })

        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait

        orders = client.retrieve_orders
        expect(orders.length).to be 2
        expect(orders[1]).to eq @orders[0]
        expect(orders[0]).to eq @orders[1]

        expect(client.retrieve_order_by_id(@orders[0].internal_id)).to eq @orders[0]
        expect(client.retrieve_order_by_id(@orders[1].internal_id)).to eq @orders[1]

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 0, :stop, {
            price:  bid - 1
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:USDJPY, :buy, -1, :stop, {
            price:         ask + 1,
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :unknown, 1, :stop, {
            price:  bid - 1
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 1, :stop)
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:USDJPY, :buy, -1, :stop, {
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            price:  0
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:         {}
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:     ask + 1,
            stop_loss_on_fill: {
              price: ask + 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            price:     bid + 1,
            stop_loss_on_fill: {
              price: bid - 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.order(:USDJPY, :buy, 1, :stop, {
            price:       ask + 1,
            take_profit_on_fill: {
              price: ask - 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:USDJPY, :sell, 1, :stop, {
            price:       bid + 1,
            take_profit_on_fill: {
              price: bid + 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end
    end

    describe 'Market If Touched注文' do
      let(:bid) { BigDecimal(tick[:EURJPY].bid, 10) }
      let(:ask) { BigDecimal(tick[:EURJPY].ask, 10) }

      it 'Market If Touched 注文ができる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        result = client.order(:EURJPY, :buy, 1, :marketIfTouched, {
          price:  ask - 1
        })
        @orders << result.order_opened
        order = @orders[0]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :marketIfTouched
        expect(order.price).to eq(ask - 1)
        expect(order.time_in_force).to eq "GTC"
        expect(order.gtd_time).to eq nil
        expect(order.price_bound).to be nil
        expect(order.position_fill).to eq "DEFAULT"
        expect(order.trigger_condition).to eq "DEFAULT"
        expect(order.client_extensions).to be nil
        expect(order.take_profit_on_fill).to be nil
        expect(order.stop_loss_on_fill).to be nil

        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait

        result = client.order(:EURJPY, :sell, 2, :marketIfTouched, {
          price:         bid + 1,
          price_bound:   bid + 0.95,
          time_in_force: 'GTD',
          gtd_time: now + (60 * 60 * 24),
          position_fill: "REDUCE_FIRST",
          trigger_condition: "BID",
          client_extensions: {
            id: "clientId",
            tag: "clientTag",
            comment: "clientComment"
          },
          take_profit_on_fill: {
            price: bid - 2,
            time_in_force: "GTD",
            gtd_time: now + (60 * 60 * 24)
          },
          stop_loss_on_fill: {
            price: bid + 2,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId2",
              tag: "clientTag",
              comment: "clientComment"
            },
          },
          trailing_stop_loss_on_fill: {
            distance: 5,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId3",
              tag: "clientTag",
              comment: "clientComment"
            }
          },
          trade_client_extensions: {
            id: "tradeClientId",
            tag: "tradeClientTag",
            comment: "tradeClientComment"
          }
        })
        @orders << result.order_opened
        order = @orders[1]
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 2
        expect(order.type).to be :marketIfTouched
        expect(order.price).to eq(bid + 1)
        expect(order.time_in_force).to eq "GTD"
        expect(order.gtd_time).to eq  now + (60 * 60 * 24)
        expect(order.price_bound).to eq bid + 0.95
        expect(order.position_fill).to eq "REDUCE_FIRST"
        expect(order.trigger_condition).to eq "BID"
        expect(order.client_extensions).to eq({
          id: "clientId",
          tag: "clientTag",
          comment: "clientComment"
        })
        expect(order.take_profit_on_fill).to eq({
          price: bid - 2,
          time_in_force: "GTD",
          gtd_time: now + (60 * 60 * 24)
        })
        expect(order.stop_loss_on_fill).to eq({
          price: bid + 2,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId2",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trailing_stop_loss_on_fill).to eq({
          distance: 5,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId3",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trade_client_extensions).to eq({
          id: "tradeClientId",
          tag: "tradeClientTag",
          comment: "tradeClientComment"
        })

        expect(result.trade_opened).to be nil
        expect(result.trade_reduced).to be nil
        expect(result.trades_closed).to eq []

        sleep wait

        orders = client.retrieve_orders
        expect(orders.length).to be 2
        expect(orders[1]).to eq @orders[0]
        expect(orders[0]).to eq @orders[1]

        expect(client.retrieve_order_by_id(@orders[0].internal_id)).to eq @orders[0]
        expect(client.retrieve_order_by_id(@orders[1].internal_id)).to eq @orders[1]

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, -1, :marketIfTouched, {
            price:  ask - 1
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 0, :marketIfTouched, {
            price:  bid + 1
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it '売/買種別が不明な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :unknown, 1, :marketIfTouched, {
            price: ask - 1
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceが未指定の場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched)
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :marketIfTouched, {
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:  0
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 2, :marketIfTouched, {
            price:         {}
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:     ask - 1,
            stop_loss_on_fill: {
              price: ask + 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 1, :marketIfTouched, {
            price:     bid + 1,
            stop_loss_on_fill: {
              price: bid - 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              }
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.order(:EURJPY, :buy, 1, :marketIfTouched, {
            price:       ask - 1,
            take_profit_on_fill: {
              price: ask - 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.order(:EURJPY, :sell, 1, :marketIfTouched, {
            price:       bid + 1,
            take_profit_on_fill: {
              price: bid + 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end
    end

    it '注文方法が不明な場合、エラーになる' do
      bid = BigDecimal(tick[:USDJPY].bid, 10)

      expect do
        client.order(:EURJPY, :buy, 0, :unknown)
      end.to raise_exception(OandaApiV20::RequestError)

      expect do
        client.order(:USDJPY, :sell, -1, :unknown)
      end.to raise_exception(OandaApiV20::RequestError)
    end

    describe '指値注文の変更' do
      let(:ask) { BigDecimal(tick[:EURJPY].ask, 10) }
      let(:bid) { BigDecimal(tick[:EURJPY].bid, 10) }

      before(:example) do
        @orders << client.order(:EURJPY, :buy, 1, :limit, {
          price:  ask - 1
        }).order_opened
        @orders << client.order(:EURJPY, :sell, 1, :limit, {
          price:  bid + 1
        }).order_opened

        sleep wait

        @buy_order  = @orders[0]
        @sell_order = @orders[1]
      end

      it '指値注文を変更できる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        order = client.modify_order(@sell_order.internal_id, {
          units:         2
        })
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 2
        expect(order.type).to be :limit
        expect(order.price).to eq(bid + 1)
        expect(order.time_in_force).to eq "GTC"
        expect(order.gtd_time).to eq nil
        expect(order.price_bound).to be nil
        expect(order.position_fill).to eq "DEFAULT"
        expect(order.trigger_condition).to eq "DEFAULT"
        expect(order.client_extensions).to be nil
        expect(order.take_profit_on_fill).to be nil
        expect(order.stop_loss_on_fill).to be nil

        order = client.modify_order(@buy_order.internal_id, {
          units:         2,
          price:         ask - 1.5,
          time_in_force: 'GTD',
          gtd_time: now + (60 * 60 * 20),
          position_fill: "REDUCE_FIRST",
          trigger_condition: "BID",
          client_extensions: {
            id: "clientId",
            tag: "clientTag",
            comment: "clientComment"
          },
          take_profit_on_fill: {
            price: ask + 2,
            time_in_force: "GTD",
            gtd_time: now + (60 * 60 * 24)
          },
          stop_loss_on_fill: {
            price: ask - 2,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId2",
              tag: "clientTag",
              comment: "clientComment"
            },
          },
          trailing_stop_loss_on_fill: {
            distance: 5,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId3",
              tag: "clientTag",
              comment: "clientComment"
            }
          },
          trade_client_extensions: {
            id: "tradeClientId",
            tag: "tradeClientTag",
            comment: "tradeClientComment"
          }
        })
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 2
        expect(order.type).to be :limit
        expect(order.price).to eq(ask - 1.5)
        expect(order.time_in_force).to eq "GTD"
        expect(order.gtd_time).to eq now + (60 * 60 * 20)
        expect(order.price_bound).to eq nil
        expect(order.position_fill).to eq "REDUCE_FIRST"
        expect(order.trigger_condition).to eq "BID"
        expect(order.client_extensions).to eq({
          id: "clientId",
          tag: "clientTag",
          comment: "clientComment"
        })
        expect(order.take_profit_on_fill).to eq({
          price: ask + 2,
          time_in_force: "GTD",
          gtd_time: now + (60 * 60 * 24)
        })
        expect(order.stop_loss_on_fill).to eq({
          price: ask - 2,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId2",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trailing_stop_loss_on_fill).to eq({
          distance: 5,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId3",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trade_client_extensions).to eq({
          id: "tradeClientId",
          tag: "tradeClientTag",
          comment: "tradeClientComment"
        })

        sleep wait

        loaded = client.retrieve_order_by_id(order.internal_id)
        expect(order).to eq loaded

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         0
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         -1
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         -1
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            price:         {},
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            stop_loss_on_fill: {
              price: ask + 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         bid + 1.5,
            stop_loss_on_fill: {
              price: bid - 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            take_profit_on_fill: {
              price: ask - 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         bid + 1.5,
            take_profit_on_fill: {
              price: bid + 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end
    end

    describe '逆指値注文の変更' do
      let(:ask) { BigDecimal(tick[:USDJPY].ask, 10) }
      let(:bid) { BigDecimal(tick[:USDJPY].bid, 10) }

      before(:example) do
        @orders << client.order(:USDJPY, :sell, 10, :stop, {
          price:  bid - 1
        }).order_opened
        @orders << client.order(:USDJPY, :buy, 1, :stop, {
          price:  ask + 1
        }).order_opened

        sleep wait

        @sell_order = @orders[0]
        @buy_order  = @orders[1]
      end

      it '逆指値注文を変更できる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        order = client.modify_order(@buy_order.internal_id, {
          price: ask + 1.2
        })
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :USDJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 1
        expect(order.type).to be :stop
        expect(order.price).to eq(ask + 1.2)
        expect(order.time_in_force).to eq "GTC"
        expect(order.gtd_time).to eq nil
        expect(order.price_bound).to be nil
        expect(order.position_fill).to eq "DEFAULT"
        expect(order.trigger_condition).to eq "DEFAULT"
        expect(order.client_extensions).to be nil
        expect(order.take_profit_on_fill).to be nil
        expect(order.stop_loss_on_fill).to be nil

        order = client.modify_order(@sell_order.internal_id, {
          units:         5,
          price:         bid - 1.5,
          time_in_force: 'GTD',
          gtd_time: now + (60 * 60 * 20),
          position_fill: "REDUCE_FIRST",
          trigger_condition: "BID",
          client_extensions: {
            id: "clientId",
            tag: "clientTag",
            comment: "clientComment"
          },
          take_profit_on_fill: {
            price: bid - 2,
            time_in_force: "GTD",
            gtd_time: now + (60 * 60 * 24)
          },
          stop_loss_on_fill: {
            price: bid + 2,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId2",
              tag: "clientTag",
              comment: "clientComment"
            },
          },
          trailing_stop_loss_on_fill: {
            distance: 5,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId3",
              tag: "clientTag",
              comment: "clientComment"
            }
          },
          trade_client_extensions: {
            id: "tradeClientId",
            tag: "tradeClientTag",
            comment: "tradeClientComment"
          }
        })
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :USDJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 5
        expect(order.type).to be :stop
        expect(order.price).to eq(bid - 1.5)
        expect(order.time_in_force).to eq "GTD"
        expect(order.gtd_time).to eq now + (60 * 60 * 20)
        expect(order.price_bound).to eq nil
        expect(order.position_fill).to eq "REDUCE_FIRST"
        expect(order.trigger_condition).to eq "BID"
        expect(order.client_extensions).to eq({
          id: "clientId",
          tag: "clientTag",
          comment: "clientComment"
        })
        expect(order.take_profit_on_fill).to eq({
          price: bid - 2,
          time_in_force: "GTD",
          gtd_time: now + (60 * 60 * 24)
        })
        expect(order.stop_loss_on_fill).to eq({
          price: bid + 2,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId2",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trailing_stop_loss_on_fill).to eq({
          distance: 5,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId3",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trade_client_extensions).to eq({
          id: "tradeClientId",
          tag: "tradeClientTag",
          comment: "tradeClientComment"
        })

        sleep wait

        loaded = client.retrieve_order_by_id(order.internal_id)
        expect(order).to eq loaded

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units: 0,
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units: -1,
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            price:         0,
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            price:         {},
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         5,
            stop_loss_on_fill: {
              price: bid - 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            },
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         5,
            price:         ask + 1.5,
            stop_loss_on_fill: {
              price: ask + 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            },
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         5,
            take_profit_on_fill: {
              price: bid + 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         5,
            price:         ask + 1.5,
            take_profit_on_fill: {
              price: ask - 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end
    end

    describe 'Market If Touched 注文の変更' do
      let(:ask) { BigDecimal(tick[:EURJPY].ask, 10) }
      let(:bid) { BigDecimal(tick[:EURJPY].bid, 10) }

      before(:example) do
        @orders << client.order(:EURJPY, :buy, 1, :marketIfTouched, {
          price:  ask - 1
        }).order_opened
        @orders << client.order(:EURJPY, :sell, 1, :marketIfTouched, {
          price:  bid + 1
        }).order_opened

        sleep wait

        @buy_order  = @orders[0]
        @sell_order = @orders[1]
      end

      it 'Market If Touched 注文を変更できる' do
        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0

        order = client.modify_order(@sell_order.internal_id, {
          price:  bid + 1.5
        })
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :sell
        expect(order.units).to be 1
        expect(order.type).to be :marketIfTouched
        expect(order.price).to eq(bid + 1.5)
        expect(order.time_in_force).to eq "GTC"
        expect(order.gtd_time).to eq nil
        expect(order.price_bound).to be nil
        expect(order.position_fill).to eq "DEFAULT"
        expect(order.trigger_condition).to eq "DEFAULT"
        expect(order.client_extensions).to be nil
        expect(order.take_profit_on_fill).to be nil
        expect(order.stop_loss_on_fill).to be nil

        order = client.modify_order(@buy_order.internal_id, {
          units:         2,
          price:         ask - 1.5,
          time_in_force: 'GTD',
          gtd_time: now + (60 * 60 * 20),
          position_fill: "REDUCE_FIRST",
          trigger_condition: "BID",
          client_extensions: {
            id: "clientId",
            tag: "clientTag",
            comment: "clientComment"
          },
          take_profit_on_fill: {
            price: ask + 2,
            time_in_force: "GTD",
            gtd_time: now + (60 * 60 * 24)
          },
          stop_loss_on_fill: {
            price: ask - 2,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId2",
              tag: "clientTag",
              comment: "clientComment"
            },
          },
          trailing_stop_loss_on_fill: {
            distance: 5,
            time_in_force: "GTC",
            client_extensions: {
              id: "clientId3",
              tag: "clientTag",
              comment: "clientComment"
            }
          },
          trade_client_extensions: {
            id: "tradeClientId",
            tag: "tradeClientTag",
            comment: "tradeClientComment"
          }
        })
        expect(order.internal_id).not_to be nil
        expect(order.pair_name).to be :EURJPY
        expect(order.sell_or_buy).to be :buy
        expect(order.units).to be 2
        expect(order.type).to be :marketIfTouched
        expect(order.price).to eq(ask - 1.5)
        expect(order.time_in_force).to eq "GTD"
        expect(order.gtd_time).to eq now + (60 * 60 * 20)
        expect(order.price_bound).to eq nil
        expect(order.position_fill).to eq "REDUCE_FIRST"
        expect(order.trigger_condition).to eq "BID"
        expect(order.client_extensions).to eq({
          id: "clientId",
          tag: "clientTag",
          comment: "clientComment"
        })
        expect(order.take_profit_on_fill).to eq({
          price: ask + 2,
          time_in_force: "GTD",
          gtd_time: now + (60 * 60 * 24)
        })
        expect(order.stop_loss_on_fill).to eq({
          price: ask - 2,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId2",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trailing_stop_loss_on_fill).to eq({
          distance: 5,
          time_in_force: "GTC",
          client_extensions: {
            id: "clientId3",
            tag: "clientTag",
            comment: "clientComment"
          }
        })
        expect(order.trade_client_extensions).to eq({
          id: "tradeClientId",
          tag: "tradeClientTag",
          comment: "tradeClientComment"
        })

        sleep wait

        loaded = client.retrieve_order_by_id(order.internal_id)
        expect(order).to eq loaded

        saved_positions = position_repository.retrieve_positions(backtest_id)
        expect(saved_positions.length).to be 0
      end

      it 'unitsが0以下の場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         -1,
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         0,
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'priceの形式が不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         0,
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            price:         {},
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'stop_lossが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            stop_loss_on_fill: {
              price: ask + 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            },
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         bid + 1.5,
            stop_loss_on_fill: {
              price: bid - 2,
              time_in_force: "GTC",
              client_extensions: {
                id: "clientId2",
                tag: "clientTag",
                comment: "clientComment"
              },
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end

      it 'take_profitが不正な場合、エラーになる' do
        expect do
          client.modify_order(@buy_order.internal_id, {
            units:         2,
            take_profit_on_fill: {
              price: ask - 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)

        expect do
          client.modify_order(@sell_order.internal_id, {
            units:         2,
            price:         bid + 1.5,
            take_profit_on_fill: {
              price: bid + 2,
              time_in_force: "GTD",
              gtd_time: now + (60 * 60 * 24)
            }
          })
        end.to raise_exception(OandaApiV20::RequestError)
      end
    end

    it '存在しない注文を編集すると、エラーになる' do
      expect do
        client.modify_order("unknown", {
          units:         2,
        })
      end.to raise_exception(OandaApiV20::RequestError)
    end

    it '注文をキャンセルできる' do
      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0

      bid = BigDecimal(tick[:EURJPY].bid, 10)
      ask = BigDecimal(tick[:EURJPY].ask, 10)

      client.order(:EURJPY, :buy, 1, :limit, {
        price:  ask - 1
      })
      sleep wait
      client.order(:EURJPY, :sell, 10, :stop, {
        price:  bid - 1
      })
      sleep wait
      client.order(:EURJPY, :buy, 1, :marketIfTouched, {
        price:  ask - 1
      })

      sleep wait
      orders = client.retrieve_orders
      expect(orders.length).to be 3

      orders.each do |o|
        sleep wait
        result = client.cancel_order(o.internal_id)
        expect(o).to eq(result)
      end

      sleep wait
      orders = client.retrieve_orders
      expect(orders.length).to be 0

      saved_positions = position_repository.retrieve_positions(backtest_id)
      expect(saved_positions.length).to be 0
    end

    it '存在しない注文をキャンセルすると、エラーになる' do
      expect do
        client.cancel_order("unknown")
      end.to raise_exception(OandaApiV20::RequestError)
    end
  end
end
