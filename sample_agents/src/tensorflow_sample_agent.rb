# frozen_string_literal: true

require 'jiji/model/agents/agent'
require 'date'
require 'httpclient'
require 'json'

# TensorFlowと連携してトレードするエージェントのサンプル
class TensorFlowSampleAgent

  include Jiji::Model::Agents::Agent

  def self.description
    <<~STR
      TensorFlowと連携してトレードするエージェントのサンプル
    STR
  end

  def self.property_infos
    [
      Property.new('exec_mode',
        '動作モード("collect" or "trade" or "test")', 'collect')
    ]
  end

  def post_create
    @calculator = SignalCalculator.new(broker)
    @cross = Cross.new
    @mode  = create_mode(@exec_mode)

    @graph = graph_factory.create('移動平均',
      :rate, :last, ['#FF6633', '#FFAA22'])
  end

  # 次のレートを受け取る
  def next_tick(tick)
    date = tick.timestamp.to_date
    return if !@current_date.nil? && @current_date == date

    @current_date = date

    signal = @calculator.next_tick(tick)
    @cross.next_data(signal[:ma5], signal[:ma10])

    @graph << [signal[:ma5], signal[:ma10]]
    do_trade(signal)
  end

  def do_trade(signal)
    # 5日移動平均と10日移動平均のクロスでトレード
    if @cross.cross_up?
      buy(signal)
    elsif @cross.cross_down?
      sell(signal)
    end
  end

  def buy(signal)
    close_exist_positions
    return unless @mode.do_trade?(signal, 'buy')

    result = broker.buy(:USDJPY, 10_000)
    @current_position = broker.positions[result.trade_opened.internal_id]
    @current_signal = signal
  end

  def sell(signal)
    close_exist_positions
    return unless @mode.do_trade?(signal, 'sell')

    result = broker.sell(:USDJPY, 10_000)
    @current_position = broker.positions[result.trade_opened.internal_id]
    @current_signal = signal
  end

  def close_exist_positions
    return unless @current_position

    @current_position.close
    @mode.after_position_closed(@current_signal, @current_position)
    @current_position = nil
    @current_signal = nil
  end

  def create_mode(mode)
    case mode
    when 'trade' then
      TradeMode.new
    when 'collect' then
      CollectMode.new
    else
      TestMode.new
    end
  end

  # データ収集モード
  #
  # TensorFlowでの予測を使用せずに移動平均のシグナルのみでトレードを行い、
  # 結果をDBに保存する
  #
  class CollectMode

    def do_trade?(signal, sell_or_buy)
      true
    end

    # ポジションが閉じられたら、トレード結果とシグナルをDBに登録する
    def after_position_closed(signal, position)
      TradeAndSignals.create_from(signal, position).save
    end

  end

  # テストモード
  #
  # TensorFlowでの予測を使用せずに移動平均のシグナルのみでトレードする
  # トレード結果は収集しない
  #
  class TestMode

    def do_trade?(signal, sell_or_buy)
      true
    end

    def after_position_closed(signal, position)
      # do nothing.
    end

  end

  # 取引モード
  #
  # TensorFlowでの予測を使用してトレードする。
  # トレード結果は収集しない
  #
  class TradeMode

    def initialize
      @client = HTTPClient.new
    end

    # トレードを勝敗予測をtensorflowに問い合わせる
    def do_trade?(signal, sell_or_buy)
      body = { sell_or_buy: sell_or_buy }.merge(signal)
      body.delete(:ma5)
      body.delete(:ma10)
      result = @client.post('http://localhost:5001/api/estimator', {
        body:   JSON.generate(body),
        header: {
          'Content-Type' => 'application/json'
        }
      })
      JSON.parse(result.body)['result'] == 'up'
      # up と予測された場合のみトレード
    end

    def after_position_closed(signal, position)
      # do nothing.
    end

  end

end

# トレード結果とトレード時の各種指標。
# MongoDBに格納してTensorFlowの学習データにする
class TradeAndSignals

  include Mongoid::Document

  store_in collection: 'tensorflow_example_trade_and_signals'

  field :macd_difference,    type: Float # macd - macd_signal

  field :rsi,                type: Float

  field :slope_10,           type: Float # 10日移動平均線の傾き
  field :slope_25,           type: Float # 25日移動平均線の傾き
  field :slope_50,           type: Float # 50日移動平均線の傾き

  field :ma_10_estrangement, type: Float # 10日移動平均からの乖離率
  field :ma_25_estrangement, type: Float
  field :ma_50_estrangement, type: Float

  field :profit_or_loss,     type: Float
  field :sell_or_buy,        type: Symbol
  field :entered_at,         type: Time
  field :exited_at,          type: Time

  def self.create_from(signal_data, position)
    TradeAndSignals.new do |ts|
      signal_data.each do |pair|
        next if pair[0] == :ma5 || pair[0] == :ma10

        ts.send("#{pair[0]}=".to_sym, pair[1])
      end
      ts.profit_or_loss = position.profit_or_loss
      ts.sell_or_buy    = position.sell_or_buy
      ts.entered_at     = position.entered_at
      ts.exited_at      = position.exited_at
    end
  end

end

# シグナルを計算するクラス
class SignalCalculator

  def initialize(broker)
    @broker = broker
  end

  def next_tick(tick)
    prepare_signals(tick) unless @macd
    calculate_signals(tick[:USDJPY])
  end

  def calculate_signals(tick)
    price = tick.bid
    ma5  = @ma5.next_data(price)
    ma10 = @ma10.next_data(price)
    ma25 = @ma25.next_data(price)
    ma50 = @ma50.next_data(price)

    signals = calculate_base_signals(ma5, ma10)
    calculate_slope_signals(signals, ma10, ma25, ma50)
    calculate_ma_signals(signals, price, ma10, ma25, ma50)

    signals
  end

  def calculate_base_signals(ma5, ma10)
    macd = @macd.next_data(price)
    {
      ma5:             ma5,
      ma10:            ma10,
      macd_difference: macd ? macd[:macd] - macd[:signal] : nil,
      rsi:             @rsi.next_data(price)
    }
  end

  def calculate_slope_signals(signals, ma10, ma25, ma50)
    signals.merge!({
      slope_10: ma10 ? @ma10v.next_data(ma10) : nil,
      slope_25: ma25 ? @ma25v.next_data(ma25) : nil,
      slope_50: ma50 ? @ma50v.next_data(ma50) : nil
    })
  end

  def calculate_ma_signals(signals, price, ma10, ma25, ma50)
    signals.merge!({
      ma_10_estrangement: ma10 ? calculate_estrangement(price, ma10) : nil,
      ma_25_estrangement: ma25 ? calculate_estrangement(price, ma25) : nil,
      ma_50_estrangement: ma50 ? calculate_estrangement(price, ma50) : nil
    })
  end

  def prepare_signals(tick)
    create_signals
    retrieve_rates(tick.timestamp).each do |rate|
      calculate_signals(rate.close)
    end
  end

  def create_signals
    create_macd_signals
    create_vector_signals

    @macd  = Signals::MACD.new
    @rsi   = Signals::RSI.new(9)
  end

  def create_macd_signals
    @ma5   = Signals::MovingAverage.new(5)
    @ma10  = Signals::MovingAverage.new(10)
    @ma25  = Signals::MovingAverage.new(25)
    @ma50  = Signals::MovingAverage.new(50)
  end

  def create_vector_signals
    @ma5v  = Signals::Vector.new(5)
    @ma10v = Signals::Vector.new(10)
    @ma25v = Signals::Vector.new(25)
    @ma50v = Signals::Vector.new(50)
  end

  def retrieve_rates(time)
    @broker.retrieve_rates(:USDJPY, :one_day, time - 60 * 60 * 24 * 60, time)
  end

  def calculate_estrangement(price, ma)
    ((BigDecimal(price, 10) - ma) / ma * 100).to_f
  end

end
