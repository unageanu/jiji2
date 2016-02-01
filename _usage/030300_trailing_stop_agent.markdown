---
layout: usage
title:  "インタラクティブにトレーリングストップ決済を行うBot"
class_name: "trailing_stop_agent"
nav_class_name: "lv2"
---

JijiのPush通知機能を使って、インタラクティブにトレーリングストップ決済を行うBotのサンプルです。

## トレーリングストップとは

建玉(ポジション)の決済方法の一つで、<b>「最高値を更新するごとに、逆指値の決済価格を切り上げていく」決済ロジック</b>です。

例) USDJPY/120.10で買建玉を作成。これを、10 pips でトレーリングストップする場合、

![概要](/images/usage/trailing_stop_agent/rate01.png)

- 建玉作成直後は、120.00 で逆指値決済される状態になる
- レートが 120.30 になった場合、逆指値の決済価格が高値に合わせて上昇し、120.20に切り上がる
- その後、レートが120.20 になると、逆指値で決済される

トレンドに乗っている間はそのまま利益を増やし、トレンドが変わって下げ始めたら決済する、という動きをする決済ロジックですね。


## インタラクティブにしてみる

単純なトレーリングストップだけなら証券会社が提供している機能で実現できるので、少し手を加えてインタラクティブにしてみました。

トレーリングストップでは、以下のようなパターンがありがち。

- すこし大きなドローダウンがきて、トレンド変わってないのに決済されてしまい、利益を逃した・・
- レートが急落した時に、決済が遅れて損失が広がった・・・

これを回避できるように、Botでの強制決済に加えて、<b>人が状況をみて決済するかどうか判断できる仕組み</b>をいれてみます。


## 仕様

以下のような動作をします。

![概要](/images/usage/trailing_stop_agent/rate02.png)

<div class="item">1) トレーリングストップの閾値を2段階で指定できるようにして、1つ目の閾値を超えたタイミングでは警告通知を送信。</div>

- 通知を確認して、即時決済するか、保留するか判断できる。
- 決済をスムーズに行えるよう、通知から1タップで決済を実行できるようにする。
  ![概要](/images/usage/trailing_stop_agent/notification.png)

<div class="item">2) 2つ目の閾値を超えた場合、Botが建玉を決済。</div>

- 夜間など通知を受けとっても対処できない場合を考慮して、2つ目の閾値を超えたら、強制決済するようにしておきます。
- なお、決済時にはOANDA JAPANから通知が送信されるので、Jijiからの通知は省略しました。


## Bot(エージェント)のコード

- <code>TrailingStopAgent</code>が、Botの本体。これをバックテストやリアルトレードで動作させればOKです。
   - エージェントファイルの追加の方法など、[Jijiの基本的な使い方](010000_basic_flow.html)はこちらをご覧ください。
- <code>TrailingStopAgent</code>自体は、新規に建玉を作ることはしません。
   - 裁量トレードや他のエージェントが作成した建玉を自動で監視し、トレーリングストップを行います。
   - バックテストで試す場合は、建玉を作成するエージェントと一緒に動作させてください。
- 機能の再利用ができるように、処理は<code>TrailingStopManager</code>に実装しています。
- ※[GitHubにもコミットしています](https://github.com/unageanu/jiji2/blob/master/sample_agents/src/trailing_stop_manager.rb)

<br/>

{% highlight ruby %}
# トレーリングストップで建玉を決済するエージェント
class TrailingStopAgent

  include Jiji::Model::Agents::Agent

  def self.description
    <<-STR
トレーリングストップで建玉を決済するエージェント。
 - 損益が警告を送る閾値を下回ったら、1度だけ警告をPush通知で送信。
 - さらに決済する閾値も下回ったら、建玉を決済します。
      STR
  end

  # UIから設定可能なプロパティの一覧
  def self.property_infos
    [
      Property.new('warning_limit', '警告を送る閾値', 20),
      Property.new('closing_limit', '決済する閾値',   40)
    ]
  end

  def post_create
    @manager = TrailingStopManager.new(
      @warning_limit.to_i, @closing_limit.to_i, notifier)
  end

  def next_tick(tick)
    @manager.check(broker.positions, broker.pairs)
  end

  def execute_action(action)
    @manager.process_action(action, broker.positions) || '???'
  end

  def state
    {
      trailing_stop_manager: @manager.state
    }
  end

  def restore_state(state)
    if state[:trailing_stop_manager]
      @manager.restore_state(state[:trailing_stop_manager])
    end
  end

end

# 建玉を監視し、最新のレートに基づいてトレールストップを行う
class TrailingStopManager

  # コンストラクタ
  #
  # warning_limit:: 警告を送信する閾値(pip)
  # closing_limit:: 決済を行う閾値(pip)
  # notifier:: notifier
  def initialize(warning_limit, closing_limit, notifier)
    @warning_limit = warning_limit
    @closing_limit = closing_limit
    @notifier  = notifier

    @states = {}
  end

  # 建玉がトレールストップの閾値に達していないかチェックする。
  # warning_limit を超えている場合、警告通知を送信、
  # closing_limit を超えた場合、強制的に決済する。
  #
  # positions:: 建て玉一覧(broker#positions)
  # pairs:: 通貨ペア一覧(broker#pairs)
  def check(positions, pairs)
    @states = positions.each_with_object({}) do |position, r|
      r[position.id.to_s] = check_position(position, pairs)
    end
  end

  # アクションを処理する
  #
  # action:: アクション
  # positions:: 建て玉一覧(broker#positions)
  # 戻り値:: アクションを処理できた場合、レスポンスメッセージ。
  #         TrailingStopManagerが管轄するアクションでない場合、nil
  def process_action(action, positions)
    return nil unless action =~ /trailing\_stop\_\_([a-z]+)_(.*)$/
    case $1
    when "close" then
        position = positions.find {|p| p.id.to_s == $2 }
        return nil unless position
        position.close
        return "建玉を決済しました。"
    end
  end

  # 永続化する状態。
  def state
    @states.each_with_object({}) {|s, r| r[s[0]] = s[1].state }
  end

  # 永続化された状態から、インスタンスを復元する
  def restore_state(state)
    @states = state.each_with_object({}) do |s, r|
      state = PositionState.new( nil,
        @warning_limit, @closing_limit )
      state.restore_state(s[1])
      r[s[0]] = state
    end
  end

  private

  # 建玉の状態を更新し、閾値を超えていたら対応するアクションを実行する。
  def check_position(position, pairs)
    state = get_and_update_state(position, pairs)
    if state.under_closing_limit?
      position.close
    elsif state.under_warning_limit?
      unless state.sent_warning # 通知は1度だけ送信する
        send_notification(position, state)
        state.sent_warning = true
      end
    end
    return state
  end

  def get_and_update_state(position, pairs)
    state = create_or_get_state(position, pairs)
    state.update(position)
    state
  end

  def create_or_get_state(position, pairs)
    key = position.id.to_s
    return @states[key] if @states.include? key
    PositionState.new(
      retrieve_pip_for(position.pair_name, pairs),
      @warning_limit, @closing_limit )
  end

  def retrieve_pip_for(pair_name, pairs)
    pairs.find {|p| p.name == pair_name }.pip
  end

  def send_notification(position, state)
    message = "#{create_position_description(position)}" \
      + " がトレールストップの閾値を下回りました。決済しますか?"
    @notifier.push_notification(message,  [{
        'label'  => '決済する',
        'action' => 'trailing_stop__close_' + position.id.to_s
    }])
  end

  def create_position_description(position)
    sell_or_buy = position.sell_or_buy == :sell ? "売" : "買"
    "#{position.pair_name}/#{position.entry_price}/#{sell_or_buy}"
  end

end

class PositionState

  attr_reader :max_profit, :profit_or_loss, :max_profit_time, :last_update_time
  attr_accessor :sent_warning

  def initialize(pip, warning_limit, closing_limit)
    @pip           = pip
    @warning_limit = warning_limit
    @closing_limit = closing_limit
    @sent_warning  = false
  end

  def update(position)
    @units            = position.units
    @profit_or_loss   = position.profit_or_loss
    @last_update_time = position.updated_at

    if @max_profit.nil? || position.profit_or_loss > @max_profit
      @max_profit      = position.profit_or_loss
      @max_profit_time = position.updated_at
      @sent_warning    = false
      # 高値を更新したあと、 warning_limit を超えたら再度警告を送るようにする
    end
  end

  def under_warning_limit?
    return false if @max_profit.nil?
    difference >= @warning_limit * @units * @pip
  end

  def under_closing_limit?
    return false if @max_profit.nil?
    difference >= @closing_limit * @units * @pip
  end

  def state
    {
      "max_profit"      => @max_profit,
      "max_profit_time" => @max_profit_time,
      "pip"             => @pip,
      "sent_warning"    => @sent_warning
    }
  end

  def restore_state(state)
    @max_profit      = state["max_profit"]
    @max_profit_time = state["max_profit_time"]
    @pip             = state["pip"]
    @sent_warning    = state["sent_warning"]
  end

  private

  def difference
    @max_profit - @profit_or_loss
  end

end
{% endhighlight %}
