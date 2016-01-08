---
layout: usage
title:  "エージェントのサンプル"
class_name: "samples"
nav_class_name: "lv2"
---

<b>[移動平均を使って取り引きを行うエージェントのサンプル](https://github.com/unageanu/jiji2/blob/master/src/jiji/model/agents/builtin_files/moving_average_agent.rb)</b>

- 添付ライブラリ `Signals::MovingAverage` を利用して移動平均を算出し、デッドクロスで売、ゴールデンクロスで買注文を行います。
- また、算出した移動平均値をグラフに出力します。
- (このエージェントは、標準添付のサンプルエージェントとして、Jijiにインストールされています)


<b>[インタラクティブにトレーリングストップ決済を行うBot](http://unageanu.hatenablog.com/entry/2015/12/28/131214)</b>

- 建玉を自動監視して、トレーリングストップ決済を行うBotのサンプルです。
- 閾値を2段階で設定でき、1つ目の閾値を超えたタイミングでは警告通知を送信。決済するか、保留するか判断できるようになっています。
- 2つ目の閾値を超えた場合、Botが建玉を強制決済します。

<b>[トラップリピートイフダンのような注文を発行するエージェント](http://unageanu.hatenablog.com/entry/2016/01/08/113507)</b>

- マネースクウェアジャパン（M2J) 様で提供されているトラップリピートイフダンのような注文を発行するエージェントのサンプルです。
- トラップリピートイフダンの詳細は、[マネースクウェアジャパン様の解説サイト](https://www.toraripifx.com/)がわかりやすいので、そちらをご覧ください。
- ※トラップリピートイフダン(トラリピ)は、マネースクウェアジャパン（M2J）様の登録商標です。


<div class="next">
  <a href="021000_library.html">次のページへ: 添付ライブラリ</a>
</div>
