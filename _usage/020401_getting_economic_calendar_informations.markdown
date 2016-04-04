---
layout: usage
title:  "日銀短観など、経済指標の開示情報を取得する"
class_name: "getting_financial_and_economic_data"
nav_class_name: "lv2"
---

日銀短観や米国雇用統計といった、各種経済指標の開示情報を取得することができます。<br/>
開示の内容に応じてトレード戦略を切り替えるようなエージェントを作成することが可能です。

<div class="notice">
※情報の取得には、 <a href="http://developer.oanda.com/docs/jp/v1/forex-labs/#section" target="_blank">ODANDA API Labsで提供されている機能</a> を利用しています。<br/>
こちらもあわせてご覧ください。
</div>

開示情報は `broker#retrieve_economic_calendar_informations` で取得できます。

{% highlight ruby %}
# 経済イベントの情報を取得します。
#
# 最初の引数で、データを取得する期間を指定します。以下のいずれかが指定可能です。
#  3600     .. 直近1時間
#  43200    .. 12時間
#  86400    .. 1日
#  604800   .. 1週間
#  2592000  .. 1ヶ月
#  7776000  .. 3ヶ月
#  15552000 .. 6ヶ月
#  31536000 .. 1年
#
# 第2引数で、取得対象とする通貨ペアの名前を指定できます。
# 指定がない場合、すべての通貨ペアの情報を取得します。
informations = broker.retrieve_economic_calendar_informations(604800, :USDJPY)
informations.each do |info|
  logger.info info.title      # タイトル  例) Chicago PMI
  logger.info info.timestamp  # 開示時刻
  logger.info info.currency   # イベントに関連する通貨 例) EUR
  logger.info info.forecast   # フォーキャストの値
  logger.info info.previous   # 同イベントの前回リリース時の値
  logger.info info.actual     # 実際値。イベントが実際に起こった後でのみ、取得可能になります。
  logger.info info.market     # 市場が期待した値
  logger.info info.unit       # forecast, previous, actual の各フィールドにおけるデータの形式。　
  logger.info info.region     # 地域 例)
end
{% endhighlight %}

<div class="warn">
<b>※現在時刻を起点とした経済イベント情報のみ取得できます。</b><br/>
バックテスト内でも実行することはできますが、返されるのは<b>テスト内の時間時点の情報ではない</b>
のでご注意ください。
</div>

<div class="next">
  <a href="020500_graphing.html">次のページへ: グラフを描く</a>
</div>
