---
layout: usage
title:  "グラフを描く"
class_name: "graphing"
nav_class_name: "lv2"
---

エージェントでグラフデータを出力しておくことで、 ローソク足チャートにグラフを描くことができます。
移動平均線やMACDなどをグラフとして表示して、エージェントの動作検証に利用できます。

グラフを描くには、`graph_factory` を使用します。必要な手順は次の通りです。

1. `graph_factory#create(label, type, aggregation_type, colors, axises)`で、名前やオプションを指定してグラフ( `Graph` )を作成
2. `Graph#<<(values)` でグラフデータを出力します

{% highlight ruby %}
# Graphを作成。
@moving_average_graph = graph_factory.create('移動平均線',
   :rate, :average, ['#FFCC33', '#FF6633'])
@rsi_graph = graph_factory.create('RSI',
    :line, :average, ['#666699'], [30, 70])

...(略)

# グラフのデータを出力。
# 値は配列で指定します。
@moving_average_graph << [45, 43]
@rsi_graph << [40]
{% endhighlight %}

`graph_factory#create(label, type, aggregation_type, colors, axises)` の引数は次の通りです。

<table>
  <tr>
    <th style="width: 6%">番号</th>
    <th style="width: 15%">名前</th>
    <th>説明</th>
  </tr>
  <tr>
    <td class="center">1</td>
    <td>label</td>
    <td>グラフの名前を指定します。<b>(必須)</b></td>
  </tr>
  <tr>
    <td class="center">2</td>
    <td>type</td>
    <td>
      グラフの種類を指定します。以下のいずれかを指定します。
      <ul>
        <li><code>:rate</code> .. グラフをレート情報に重ねて表示します。移動平均線やボリンジャーバンド向けです。</li>
        <li><code>:line</code> .. 通常の線グラフとして描画します。グラフは、チャートの下の部分に表示されます。</li>
      </ul>
      省略した場合、 <code>:line</code>が使用されます。
    </td>
  </tr>
  <tr>
    <td class="center">3</td>
    <td>aggregation_type</td>
    <td>
      グラフの集計方法を指定します。「15秒ごとにグラフデータを出力したとき、15分足でどのデータを使うか」を決定する際に使用されます。
      指定可能な値は以下の3つです。
      <ul>
        <li><code>:average</code> .. 期間内に出力されたデータの平均値を使用します。</li>
        <li><code>:first</code> .. 期間内に出力された最初のデータを使用します。</li>
        <li><code>:last</code> .. 期間内に出力された最後のデータを使用します。</li>
      </ul>
      省略した場合、 <code>:first</code>が使用されます。
    </td>
  </tr>
  <tr>
    <td class="center">4</td>
    <td>colors</td>
    <td>
      グラフの色を"#FFFFFF"形式の配列で指定します。
    </td>
  </tr>
  <tr>
    <td class="center">5</td>
    <td>axises</td>
    <td>
      グラフの背景に描画するy軸のメモリを配列で指定します。グラフの種類が <code>:line</code>の場合のみ有効です。
    </td>
  </tr>
</table>

<div class="next">
  <a href="020500_messaging.html">次のページへ: Push通知・メールを送信する</a>
</div>
