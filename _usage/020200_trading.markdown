---
layout: usage
title:  "取引を行う"
class_name: "trading"
nav_class_name: "lv2"
---

取引を行うには、`broker` を使用します。 `broker` は、 `Agent`のインスタンス変数として初期化時に設定されます。


<h3>注文を行う</h3>

成行、指値、逆指値、Market If Touched で注文を行うことができます。<br/>
以下、各種注文を行う例です。

{% highlight ruby %}
# EURJPYを10000単位、成行で売り
broker.sell(:EURJPY, 10000)
# 各種オプションを指定して、EURJPYを10000単位、成行で買い
broker.buy(:EURJPY,  10000, :market, {
  lower_bound:   135.61,  #成立下限価格
  upper_bound:   135.59,  #成立上限価格

  # 建玉の約定条件
  stop_loss:     135.23,  #ストップロス価格
  take_profit:   135.73,  #テイクプロフィット価格
  trailing_stop: 10       #トレーリングストップのディスタンスをpipsで指定します。  
})

# 指値135.6で売り注文
broker.sell(:USDJPY, 10000, :limit, {
  price:         122.6,
  expiry:        Time.utc(2015, 5, 2)  #注文の有効期限
})

# 逆指値112.404で買い注文
broker.buy(:USDJPY, 10000, :stop, {
  price:       112.404,
  expiry:      Time.utc(2015, 5, 2),

  # lower_bound等のオプションは、注文方法によらず指定可能です。
  lower_bound:   135.61,
  upper_bound:   135.59,
  stop_loss:     135.23,
  take_profit:   135.73,
  trailing_stop: 10
})

# Market If Touched で買い
broker.buy(:EURUSD, 10000, :marketIfTouched, {
  price:         1.4325,
  expiry:        Time.utc(2015, 5, 2)
})
{% endhighlight %}

`sell(pair_name, units, type, options)`, `buy(pair_name, units, type, options)` の引数は次の通りです。

<table>
  <tr>
    <th style="width: 6%">番号</th>
    <th style="width: 15%">名前</th>
    <th>説明</th>
  </tr>
  <tr>
    <td class="center">1</td>
    <td>pair_name</td>
    <td>取引する通貨ペアを、<code>:EURJPY</code> のようなシンボルで指定します。<b>(必須)</b></td>
  </tr>
  <tr>
    <td class="center">2</td>
    <td>units</td>
    <td>
      注文単位を指定します。<b>(必須)</b><br/>
      OANDA JApan では、1単位からの取引が可能です。
    </td>
  </tr>
  <tr>
    <td class="center">3</td>
    <td>type</td>
    <td>
      取引の種別を指定します。<br/>
      成行 (<code>:market</code>)、指値 (<code>:limit</code>)、逆指値 (<code>stop</code>)、
      Market If Touched (<code>:marketIfTouched</code>) のいずれかが指定可能です。<br/>
      省略した場合、成行(<code>:market</code>) 注文になります。
    </td>
  </tr>
  <tr>
    <td class="center">4</td>
    <td>options</td>
    <td>
      指値注文の指値価格や、有効期限などを指定します。<br/>
      指定可能なパラメータについては、<a href="http://developer.oanda.com/docs/jp/v1/orders/#create-a-new-order">こちら</a>を参照ください。
    </td>
  </tr>
</table>


注文を行うと、 [OrderResult](/rdocs/Jiji/Model/Trading/OrderResult.html) が返却されます。

<h3>注文一覧を取得する</h3>
`Broker#orders` で、注文一覧を取得できます。

{% highlight ruby %}
orders = broker.orders # Orderの配列が返されます。
orders.length
orders.find { |o| o.sell_or_buy == :sell } #売り注文の一覧を取得
{% endhighlight %}


<h3>注文を変更する</h3>
指値や決済条件は、 `Broker#modify_order(order)` または、 `Order#modify` で変更することが可能です。

{% highlight ruby %}
order = broker.orders[0]

# 変更
order.price = 135.7
order.expiry = Time.utc(2015, 5, 3)
order.lower_bound = 135.69
order.upper_bound = 135.71
order.stop_loss = 135.83
order.take_profit = 135.63
order.trailing_stop = 10

# 変更を反映
broker.modify_order(order)
# or
order.modify
{% endhighlight %}

変更可能なプロパティについては、<a href="http://developer.oanda.com/docs/jp/v1/orders/#modify-an-existing-order">こちら</a>を参照ください。


<h3>注文をキャンセルする</h3>
約定していない注文は、 `Broker#cancel_order(order)` または、 `Order#cancel` でキャンセルできます。

{% highlight ruby %}
order = broker.orders[0]

# 注文をキャンセル
broker.cancel_order(order)
# or
order.cancel
{% endhighlight %}

<h3>建玉一覧を取得する</h3>
注文が約定すると、 建玉( `Position` )が生成されます。<br/>
`Broker#positions` で、現在の建玉一覧を取得できます。

{% highlight ruby %}
positions = broker.positions # Positions オブジェクトが返されます
positions.length
positions..find { |o| o.sell_or_buy == :sell } #売建玉の一覧を取得
{% endhighlight %}

建玉オブジェクトからは、購入レートや現在の損益が取得できます。

{% highlight ruby %}
# 建玉
position = broker.positions[0]

position.internal_id     # 一意な識別子
position.pair_name       # 通貨ペア 例) :EURJPY
position.units           # 取引単位
position.sell_or_buy     # 売(:sell) or 買(:buy)

# ステータス
# - 新規   .. :live
# - 決済済 .. :closed
# - ロスト .. :lost
#   (決済前にシステムが再起動された場合、ロスト状態になります)
position.status

position.profit_or_loss  # 損益
position.max_drow_down   # 最大ドローダウン

position.entry_price     # 購入価格
position.current_price   # 現在価格
position.exit_price      # 決済価格 (未決済の場合 nil)

position.entered_at      # 購入日時
position.exited_at       # 決済日時 (未決済の場合 nil)
position.updated_at      # 最終更新時刻

# 決済条件
position.closing_policy.take_profit     # テイクプロフィット価格
position.closing_policy.stop_loss       # ストップロス価格
position.closing_policy.trailing_stop   # トレーリングストップディスタンス
position.closing_policy.trailing_amount # トレーリングストップ数量
{% endhighlight %}


<h3>建玉を決済する</h3>
建玉を決済するには、`Broker#close_position(position)` または、 `Position#close` を実行します。

{% highlight ruby %}
position = broker.positions.find { |p| p.sell_or_buy == :sell }[0]

# 建玉を決済
broker.close_position(position)
# or
position.close
{% endhighlight %}


<h3>建玉の決済条件を変更する</h3>

`Broker#modify_position(position)` または、 `Position#modify` で、建玉の決済条件を変更することができます。

{% highlight ruby %}
position = broker.positions.find { |p| p.sell_or_buy == :sell }[0]

# 決済条件を変更
position.closing_policy = Jiji::Model::Trading::ClosingPolicy.create({
  stop_loss:     130,
  take_profit:   140.5,
  trailing_stop: 10
})

# 変更を反映
broker.modify_position(position)
# or
position.modify
{% endhighlight %}


<div class="next">
  <a href="020300_account.html">次のページへ: 口座情報を取得する</a>
</div>
