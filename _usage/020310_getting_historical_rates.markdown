---
layout: usage
title:  "過去のレート情報を取得する"
class_name: "getting_historical_rates"
nav_class_name: "lv2"
---

[`broker#retrieve_rates`](/rdocs/Jiji/Model/Trading/Brokers/AbstractBroker.html#method-i-retrieve_rates)
で、過去のレート情報を取得することができます。

* 期間と通貨ペアを指定して、4本値 + 出来高の情報( [Rate](/rdocs/Jiji/Model/Trading/Rate.html) の配列 )を取得できます。
* 最大5000件のレート情報を一度に取得できます。それ以上のデータが必要な場合は、分割して取得してください。

{% highlight ruby %}
# 過去のレート情報を取得します。
#
# 引数で、通貨ペア、集計期間、取得開始日時、取得終了日時を指定します。
# 第2引数の集計期間には、以下のいずれかを指定できます。
#   :fifteen_seconds .. 15秒足
#   :one_minute      .. 分足
#   :fifteen_minutes .. 15分足
#   :thirty_minutes  .. 30分足
#   :one_hour        .. 1時間足
#   :six_hours       .. 6時間足
#   :one_day         .. 日足
#
rates = broker.retrieve_rates(:USDJPY, :one_hour,
  Time.utc(2016, 5, 19), Time.utc(2016, 5, 20))

rates.each do |rate|
  rate.timestamp # 時刻

  rate.open.bid  # 始値のbidレート
  rate.open.ask  # 始値のaskレート
  rate.close.bid # 終値のbidレート
  rate.close.ask # 終値のaskレート
  rate.high.bid  # 高値のbidレート
  rate.high.ask  # 高値のaskレート
  rate.low.bid   # 安値のbidレート
  rate.low.ask   # 安値のaskレート

  rate.volume    # 出来高
end
{% endhighlight %}

<div class="next">
  <a href="020400_getting_financial_and_economic_data.html">次のページへ: 各種金融・経済データを取得する</a>
</div>
