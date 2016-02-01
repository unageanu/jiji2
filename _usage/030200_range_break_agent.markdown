---
layout: usage
title:  "レンジブレイク手法を使ったトレードをアシストするBot"
class_name: "range_break_agent"
nav_class_name: "lv2"
---

レンジブレイク手法を使ったトレードをアシストするBotです。<br/>
[FX Wroks さんのサイト](http://fx-works.jp/renji-jyunbari/) に掲載されていた「レンジブレイクを狙うシンプルな順張り」手法を、そのままJijiに移植してみたものです。

## 動作

以下のような動作をします。

![概要](/images/usage/range_break_agent/summary.png)

<div class="item">1) Botがレートを監視し、レンジブレイクをチェック</div>

- 条件は、サイトの内容と同等、8時間レートが100pips内で推移したあと、上or下に抜ける、としました。
- 待つ期間やpipsは、パラメータで調整できるようにしています。

<div class="item">2) レンジブレイクを検出したら、スマホに通知を送信します</div>

- ダマしが多いので、今回は通知を送って判断する形に。

<div class="item">3) 通知を受けて最終判断を行い、トレードを実行。</div>

- 通知にあるボタンを押すことで、売or買で成行注文を実行できるようにしています。
- 決済は、トレーリングストップで。


## 軽く動かしてみた感想

軽くテストしてみましたが、思ったよりもダマしに引っかかる感じですね。

![取引1](/images/usage/range_break_agent/r1.png)

これは、まぁまぁ。

![取引1](/images/usage/range_break_agent/r3.png)

これは、ブレイクと判定された時点で下げが終わっている・・。

![取引1](/images/usage/range_break_agent/r2.png)

これは、一度上にブレイクしたあと、逆方向に進んでいます・・・。

ブレイクの条件を調整してみる、移動平均でのトレンドチェックと組み合わせるなど、カスタマイズして使ってみてください。

## コード

※[GitHubにもコミットしています](https://github.com/unageanu/jiji2/blob/master/sample_agents/src/range_break_agent.rb)

{% highlight ruby %}
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
      Property.new('target_pair',  '対象とする通貨ペア',      'USDJPY'),
      Property.new('range_period', 'レンジを判定する期間(分)',   60 * 8),
      Property.new('range_pips',    'レンジ相場とみなす値幅(pips)', 100),
      Property.new('trailing_stop_pips',
        'トレールストップで決済する値幅(pips)',                       30),
      Property.new('trade_units',   '取引数量',                      1)
    ]
  end

  def post_create
    pair = broker.pairs.find { |p| p.name == @target_pair.to_sym }
    @checker = RangeBreakChecker.new(
      pair, @range_period.to_i, @range_pips.to_i)
  end

  def next_tick(tick)
    # レンジブレイクしたかどうかチェック
    result = @checker.check_range_break(tick)
    # ブレイクしていたら通知を送る
    send_notification(result) if result[:state] != :no
  end

  def execute_action(action)
    case action
    when 'range_break_buy'  then buy
    when 'range_break_sell' then sell
    else '不明なアクションです'
    end
  end

  def state
    { checker: @checker.state }
  end

  def restore_state(state)
    @checker.restore_state(state[:checker]) if state[:checker]
  end

  private

  def sell
    broker.sell(@target_pair.to_sym, @trade_units.to_i, :market, {
      trailing_stop: @trailing_stop_pips.to_i
    })
    '売注文を実行しました'
  end

  def buy
    broker.buy(@target_pair.to_sym, @trade_units.to_i, :market, {
      trailing_stop: @trailing_stop_pips.to_i
    })
    '買注文を実行しました'
  end

  def send_notification(result)
    message = "#{@target_pair} #{result[:price]}" \
      + ' がレンジブレイクしました。取引しますか?'
    @notifier.push_notification(message, [create_action(result)])
    logger.info "#{message} #{result[:state]} #{result[:time]}"
  end

  def create_action(result)
    if result[:state] == :break_high
      { 'label'  => '買注文を実行', 'action' => 'range_break_buy' }
    else
      { 'label'  => '売注文を実行', 'action' => 'range_break_sell' }
    end
  end

end

class RangeBreakChecker

  def initialize(pair, period, range_pips)
    @pair       = pair
    @range_pips = range_pips
    @candles    = Candles.new(period * 60)
  end

  def check_range_break(tick)
    tick_value = tick[@pair.name]
    result = check_state(tick_value, tick.timestamp)
    @candles.reset unless result == :no
    # 一度ブレイクしたら、一旦状態をリセットして次のブレイクを待つ
    @candles.update(tick_value, tick.timestamp)
    {
      state: result,
      price: tick_value.bid,
      time:  tick.timestamp
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

    diff = highest - lowest
    return :no if diff >= @range_pips * @pair.pip
    calculate_state( tick_value, highest, diff )
  end

  def calculate_state( tick_value, highest, diff )
    center = highest - diff / 2
    pips = @range_pips / 2 * @pair.pip
    if tick_value.bid >= center + pips
      return :break_high
    elsif tick_value.bid <= center - pips
      return :break_low
    end
    :no
  end

  def over_period?(time)
    oldest_time = @candles.oldest_time
    return false unless oldest_time
    (time.to_i - oldest_time.to_i) >= @candles.period
  end

end

class Candles

  attr_reader :period

  def initialize(period)
    @candles     = []
    @period      = period
    @next_update = nil
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
    high = @candles.max_by { |c| c.high }
    high.nil? ? nil : BigDecimal.new(high.high, 10)
  end

  def lowest
    low = @candles.min_by { |c| c.low }
    low.nil? ? nil : BigDecimal.new(low.low, 10)
  end

  def oldest_time
    oldest = @candles.min_by { |c| c.time }
    oldest.nil? ? nil : oldest.time
  end

  def reset
    @candles     = []
    @next_update = nil
  end

  def new_candle(tick_value, time)
    limit = time - period
    @candles = @candles.reject { |c| c.time < limit }

    @candles << Candle.new
    @candles.last.update(tick_value, time)

    @next_update = time + (60 * 5)
  end

  def state
    {
      candles:     @candles.map { |c| c.to_h },
      next_update: @next_update
    }
  end

  def restore_state(state)
    @candles = state[:candles].map { |s| Candle.from_h(s) }
    @next_update = state[:next_update]
  end

  def self.normalize_time(time)
    Time.at((time.to_i / (60 * 5)).floor * 60 * 5)
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
    @low  = price if @low.nil?  || @low > price
    @time = time  if @time.nil?
  end

  def to_h
    { high: @high, low: @low, time: @time }
  end

  def self.from_h(hash)
    Candle.new(hash[:high], hash[:low], hash[:time])
  end

  private

  def extract_price(tick_value)
    tick_value.bid
  end

end
{% endhighlight %}
