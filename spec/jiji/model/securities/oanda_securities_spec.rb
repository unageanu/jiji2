# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'

describe Jiji::Model::Securities::OandaSecurities do
  before(:example) do
    @client = Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end

  after(:example) do
  end

  it '不正なトークンを指定した場合、エラー' do
    expect do
      Jiji::Model::Securities::OandaDemoSecurities.new(
        access_token: 'illegal_token')
    end.to raise_exception(OandaAPI::RequestError)
  end

  describe 'find_account' do
    it '名前に対応するアカウントを取得できる。' do
      account = @client.find_account('Primary')
      # p account
      expect(account.account_name).to eq 'Primary'
      expect(account.account_id).to be > 0
      expect(account.account_currency).to eq 'JPY'
      expect(account.margin_rate).not_to be nil
    end

    it '名前に対応するアカウントが見つからない場合、エラー' do
      expect do
        @client.find_account('not_found')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe 'pairs' do
    it '通貨ペアの一覧を取得できる。' do
      pairs = @client.retrieve_pairs
      # p pairs
      expect(pairs.length).to be > 0
      pairs.each do |pair|
        expect(pair.name).not_to be nil
        expect(pair.internal_id).not_to be nil
        expect(pair.pip).to be > 0
        expect(pair.max_trade_units).to be > 0
        expect(pair.precision).to be > 0
        expect(pair.margin_rate).to be > 0
      end
    end
  end

  describe 'retrieve_current_tick' do
    it '通貨ペアごとの現在価格を取得できる。' do
      tick = @client.retrieve_current_tick
      # p tick
      expect(tick.length).to be > 0
      expect(tick.timestamp).not_to be nil
      expect(tick.timestamp.class).to be Time
      tick.each do |_k, v|
        expect(v.bid).to be > 0
        expect(v.ask).to be > 0
      end
    end
  end

  describe 'retrieve_tick_history' do
    it '通貨ペアの価格履歴を取得できる。' do
      ticks = @client.retrieve_tick_history(:EURJPY,
        Time.utc(2015, 5, 22, 12, 00, 00), Time.utc(2015, 5, 22, 12, 15, 00))
      # p ticks
      expect(ticks.length).to be 15 * 4
      time = Time.utc(2015, 5, 22, 12, 00, 00)
      ticks.each do |tick|
        expect(tick.timestamp).to eq time
        expect(tick.length).to be 1
        v = tick[:EURJPY]
        expect(v.bid).to be > 0
        expect(v.ask).to be > 0
        time = Time.at(time.to_i + 15).utc
      end
    end
  end

  describe 'retrieve_rate_history' do
    it '通貨ペアの4本値の履歴を取得できる。' do
      rates = @client.retrieve_rate_history(:EURJPY, :one_hour,
        Time.utc(2015, 5, 21, 12, 00, 00), Time.utc(2015, 5, 22, 12, 00, 00))
      # p ticks
      expect(rates.length).to be 24
      time = Time.utc(2015, 5, 21, 12, 00, 00)
      rates.each do |rate|
        expect(rate.timestamp).to eq time
        expect(rate.open.bid).to be > 0
        expect(rate.open.ask).to be > 0
        expect(rate.close.bid).to be > 0
        expect(rate.close.ask).to be > 0
        expect(rate.high.bid).to be > 0
        expect(rate.high.ask).to be > 0
        expect(rate.low.bid).to be > 0
        expect(rate.low.ask).to be > 0
        time = Time.at(time.to_i + 60 * 60).utc
      end
    end
  end

  describe 'orders' do

    let(:tick) do @client.retrieve_current_tick end
    let(:now) do  Time.now.round end

    before(:example) do
      @orders = []
    end

    after(:example) do
      @orders.each do |o|
        begin
          @client.cancel_order( o.internal_id )
        rescue
          p $!
        end
      end
    end

    it '指値で注文ができる' do

      bid = BigDecimal.new(tick[:EURJPY].bid, 4)
      ask = BigDecimal.new(tick[:EURJPY].ask, 4)

      @orders <<  @client.order( :EURJPY, :buy, 1, :limit, {
        price: (ask + 1).to_f,
        expiry: (now + (60 * 60 * 24)).utc.to_datetime.rfc3339
      })
      order = @orders[0]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :EURJPY
      expect( order.sell_or_buy ).to be :buy
      expect( order.units ).to be 1
      expect( order.type ).to be :limit
      expect( order.price ).to eq (ask + 1).to_f
      expect( order.expiry ).to eq( (now + (60 * 60 * 24)).utc)

      @orders <<  @client.order( :EURJPY, :sell, 2, :limit, {
        price: (bid - 1).to_f,
        expiry: (now + (60 * 60 * 24)).utc.to_datetime.rfc3339,
        lower_bound: (bid + 0.05).to_f,
        upper_bound: (bid - 0.05).to_f,
        stop_loss:   (bid).to_f,
        take_profit: (bid - 2).to_f,
        trailing_stop: 5
      })
      order = @orders[1]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :EURJPY
      expect( order.sell_or_buy ).to be :sell
      expect( order.units ).to be 2
      expect( order.type ).to be :limit
      expect( order.price ).to eq (bid - 1).to_f
      expect( order.expiry ).to eq((now + (60 * 60 * 24)).utc)
      expect( order.lower_bound ).to eq (bid + 0.05).to_f
      expect( order.upper_bound ).to eq (bid - 0.05).to_f
      expect( order.stop_loss ).to eq (bid).to_f
      expect( order.take_profit ).to eq (bid - 2).to_f
      expect( order.trailing_stop ).to eq 5

      orders = @client.retrieve_orders
      expect( orders.length ).to be 2
      order = orders[1]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :EURJPY
      expect( order.sell_or_buy ).to be :buy
      expect( order.units ).to be 1
      expect( order.type ).to be :limit
      expect( order.price ).to eq (ask + 1).to_f
      expect( order.expiry ).to eq( (now + (60 * 60 * 24)).utc)
      order = orders[0]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :EURJPY
      expect( order.sell_or_buy ).to be :sell
      expect( order.units ).to be 2
      expect( order.type ).to be :limit
      expect( order.price ).to eq (bid - 1).to_f
      expect( order.expiry ).to eq((now + (60 * 60 * 24)).utc)
      expect( order.lower_bound ).to eq (bid + 0.05).to_f
      expect( order.upper_bound ).to eq (bid - 0.05).to_f
      expect( order.stop_loss ).to eq (bid).to_f
      expect( order.take_profit ).to eq (bid - 2).to_f
      expect( order.trailing_stop ).to eq 5

      order = @client.retrieve_order_by_id(orders[1].internal_id)
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :EURJPY
      expect( order.sell_or_buy ).to be :buy
      expect( order.units ).to be 1
      expect( order.type ).to be :limit
      expect( order.price ).to eq (ask + 1).to_f
      expect( order.expiry ).to eq( (now + (60 * 60 * 24)).utc)

      order = @client.retrieve_order_by_id(orders[0].internal_id)
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :EURJPY
      expect( order.sell_or_buy ).to be :sell
      expect( order.units ).to be 2
      expect( order.type ).to be :limit
      expect( order.price ).to eq (bid - 1).to_f
      expect( order.expiry ).to eq((now + (60 * 60 * 24)).utc)
      expect( order.lower_bound ).to eq (bid + 0.05).to_f
      expect( order.upper_bound ).to eq (bid - 0.05).to_f
      expect( order.stop_loss ).to eq (bid).to_f
      expect( order.take_profit ).to eq (bid - 2).to_f
      expect( order.trailing_stop ).to eq 5
    end

    it '逆指値で注文ができる' do

      bid = BigDecimal.new(tick[:USDJPY].bid, 4)
      ask = BigDecimal.new(tick[:USDJPY].ask, 4)

      @orders <<  @client.order( :USDJPY, :sell, 10, :stop, {
        price: (bid + 1).to_f,
        expiry: (now + (60 * 60 * 24)).utc.to_datetime.rfc3339
      })
      order = @orders[0]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :USDJPY
      expect( order.sell_or_buy ).to be :sell
      expect( order.units ).to be 10
      expect( order.type ).to be :stop
      expect( order.price ).to eq (bid + 1).to_f
      expect( order.expiry ).to eq( (now + (60 * 60 * 24)).utc)

      @orders <<  @client.order( :USDJPY, :buy, 11, :stop, {
        price: (ask - 1).to_f,
        expiry: (now + (60 * 60 * 24)).utc.to_datetime.rfc3339,
        lower_bound: (ask + 0.05).to_f,
        upper_bound: (ask - 0.05).to_f,
        stop_loss:   (ask - 2).to_f,
        take_profit: (ask).to_f,
        trailing_stop: 5
      })
      order = @orders[1]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :USDJPY
      expect( order.sell_or_buy ).to be :buy
      expect( order.units ).to be 11
      expect( order.type ).to be :stop
      expect( order.price ).to eq (ask - 1).to_f
      expect( order.expiry ).to eq((now + (60 * 60 * 24)).utc)
      expect( order.lower_bound ).to eq (ask + 0.05).to_f
      expect( order.upper_bound ).to eq (ask - 0.05).to_f
      expect( order.stop_loss ).to eq (ask - 2).to_f
      expect( order.take_profit ).to eq (ask).to_f
      expect( order.trailing_stop ).to eq 5

      orders = @client.retrieve_orders
      expect( orders.length ).to be 2
      order = orders[1]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :USDJPY
      expect( order.sell_or_buy ).to be :sell
      expect( order.units ).to be 10
      expect( order.type ).to be :stop
      expect( order.price ).to eq (bid + 1).to_f
      expect( order.expiry ).to eq( (now + (60 * 60 * 24)).utc)
      order = orders[0]
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :USDJPY
      expect( order.sell_or_buy ).to be :buy
      expect( order.units ).to be 11
      expect( order.type ).to be :stop
      expect( order.price ).to eq (ask - 1).to_f
      expect( order.expiry ).to eq((now + (60 * 60 * 24)).utc)
      expect( order.lower_bound ).to eq (ask + 0.05).to_f
      expect( order.upper_bound ).to eq (ask - 0.05).to_f
      expect( order.stop_loss ).to eq (ask - 2).to_f
      expect( order.take_profit ).to eq (ask).to_f
      expect( order.trailing_stop ).to eq 5

      order = @client.retrieve_order_by_id(orders[1].internal_id)
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :USDJPY
      expect( order.sell_or_buy ).to be :sell
      expect( order.units ).to be 10
      expect( order.type ).to be :stop
      expect( order.price ).to eq (bid + 1).to_f
      expect( order.expiry ).to eq( (now + (60 * 60 * 24)).utc)

      order = @client.retrieve_order_by_id(orders[0].internal_id)
      expect( order.internal_id ).not_to be nil
      expect( order.pair_name ).to be :USDJPY
      expect( order.sell_or_buy ).to be :buy
      expect( order.units ).to be 11
      expect( order.type ).to be :stop
      expect( order.price ).to eq (ask - 1).to_f
      expect( order.expiry ).to eq((now + (60 * 60 * 24)).utc)
      expect( order.lower_bound ).to eq (ask + 0.05).to_f
      expect( order.upper_bound ).to eq (ask - 0.05).to_f
      expect( order.stop_loss ).to eq (ask - 2).to_f
      expect( order.take_profit ).to eq (ask).to_f
      expect( order.trailing_stop ).to eq 5
    end

    # it 'Market if touched注文ができる' do
    # end

    # it '成行きで注文ができる' do
    # end

    # it '逆指値注文を変更できる' do
    # end
    # it '指値注文を変更できる' do
    # end
    # it 'Market if touched注文を変更できる' do
    # end
    # it '注文をキャンセルできる' do
    # end

  end

end
