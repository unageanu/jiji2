
# === レンジブレイクでトレードを行うエージェント
class RangeBreakAgent

  include Jiji::Model::Agents::Agent

  def self.description
    <<-STR
レンジブレイクでトレードを行うエージェント。
 - 指定期間(デフォルトは8時間)のレートが一定のpipsに収まっている状態から、
   レンジを抜けたタイミングで通知を送信。
 - 通知からトレード可否を判断し、取引を実行できます。
 - 決済はトレーリングストップで行います。
    STR
  end

  # UIから設定可能なプロパティの一覧
  def self.property_infos
    [
      Property.new(
        'target_pair',       '対象とする通貨ペア',              "USDJPY"),
      Property.new(
        'range_period',       'レンジを判定する期間(分)',            60*8),
      Property.new(
        'range_pips',         'レンジ相場とみなす値幅(pips)',         100),
      Property.new(
        'trailing_stop_pips', 'トレールストップで決済する値幅(pips)',   30),
      Property.new(
        'trade_units',        '取引数量',                              1)
    ]
  end

  def post_create
    pair = broker.pairs.find {|p| p.name == @target_pair.to_sym }
    @checker = RangeBreakChecker.new(
      pair, @range_period.to_i, @range_pips.to_i)
  end

  def next_tick(tick)
    result = @checker.check_range_break(tick)
    if result[:state] != :no
      send_notification(result)
    end
  end

  def execute_action(action)
    case action
    when 'range_break_buy'  then buy
    when 'range_break_sell' then sell
    end
    "不明なアクションです"
  end

  def state
    { checker: @checker.state }
  end

  def restore_state(state)
    if state[:checker]
      @checker.restore_state(state[:checker])
    end
  end

  private

  def sell
    broker.sell(@target_pair.to_sym, @trade_units.to_i, :market, {
      trailing_stop: @trailing_stop_pips.to_i
    })
  end

  def buy
    broker.buy(@target_pair.to_sym, @trade_units.to_i, :market, {
      trailing_stop: @trailing_stop_pips.to_i
    })
  end

  def send_notification(result)
    message = "#{@target_pair} #{result[:price]}" \
      + ' がレンジブレイクしました。取引しますか?'
    @notifier.push_notification(message, [create_action(result)])
  end

  def create_action(result)
    if result[:state] == :break_high
      { 'label'  => '買注文を実行', 'action' => 'range_break_buy' }
    else
      { 'label'  => '売注文を実行', 'action' => 'range_break_sell'}
    end
  end

end


class RangeBreakChecker

  def initialize(pair, period, range_pips)
    @pair       = pair
    @range_pips = range_pips
    @candles    = Candles.new(period*60)
  end

  def check_range_break(tick)
    tick_value = tick[@pair.name]
    result = check_state(tick_value, tick.timestamp)
    @candles.reset unless result == :no
      #一度ブレイクしたら、一旦状態をリセットして次のブレイクを待つ
    @candles.update(tick_value, tick.timestamp)
    return {
      state: result,
      price: tick_value.bid,
      time: tick.timestamp
    }
  end

  def state
    @candles.state
  end

  def restore_state(state)
    @candles.restore_state(state)
  end

  private

  # レンジブレイクしているかどうか判定する
  def check_state(tick_value, time)
    highest = @candles.highest
    lowest  = @candles.lowest
    return :no if highest.nil? || lowest.nil?
    return :no unless over_period?(time)

    if highest - lowest <= @range_pips * @pair.pip
      if tick_value.bid >= lowest + @range_pips * @pair.pip
        return :break_high
      elsif tick_value.bid <= highest - @range_pips * @pair.pip
        return :break_low
      end
    end
    return :no
  end

  def over_period?(time)
    oldest_time = @candles.oldest_time
    return false unless oldest_time
    return (time.to_i - oldest_time.to_i) >= @candles.period
  end

end

class Candles

  attr_reader :period

  def initialize(period)
    @candles     = []
    @period      = period
    @next_update =  nil
  end

  def update(tick_value, time)
    time = Candles.normalize_time(time)
    if @next_update.nil? || time > @next_update
      new_candle(tick_value, time)
    else
      @candles.last.update(tick_value, time)
    end
  end

  def highest
    high = @candles.max_by {|c| c.high }
    return high.nil? ? nil : BigDecimal.new(high.high, 10)
  end

  def lowest
    low = @candles.min_by {|c| c.low }
    return low.nil? ? nil : BigDecimal.new(low.low, 10)
  end

  def oldest_time
    oldest = @candles.min_by {|c| c.time }
    return oldest.nil? ? nil : oldest.time
  end

  def reset
    @candles     = []
    @next_update = nil
  end

  def new_candle(tick_value, time)
    limit = time - period
    @candles = @candles.reject {|c| c.time < limit }

    @candles << Candle.new
    @candles.last.update(tick_value, time)

    @next_update = time + (60 * 5)
  end

  def state
    {
      candles:      @candles.map {|c| c.to_h },
      next_update:  @next_update
    }
  end

  def restore_state(state)
    @candles = state[:candles].map {|s| Candle.from_h(s) }
    @next_update = state[:next_update]
  end

  def self.normalize_time(time)
    Time.at((time.to_i / (60*5)).floor * 60*5)
  end

end

class Candle

  attr_reader :high, :low, :time

  def initialize(high = nil, low = nil, time = nil)
    @high = high
    @low  = low
    @time = time
  end

  def update(tick_value, time)
    price = extract_price(tick_value)
    @high = price if @high.nil? || @high < price
    @low  = price if @low.nil?  || @low  > price
    @time = time  if @time.nil?
  end

  def to_h
    {high: @high, low: @low, time: @time}
  end

  def self.from_h(hash)
    Candle.new(hash[:high], hash[:low], hash[:time])
  end

  private

  def extract_price(tick_value)
    tick_value.bid
  end

end
