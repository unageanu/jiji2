---
layout: usage
title:  "口座情報を取得する"
class_name: "account"
nav_class_name: "lv2"
---

口座情報から、口座残高などを参照できます。口座情報は `broker` から取得します。

{% highlight ruby %}
account = broker.account

account.balance     # 口座残高
account.account_id  # アカウントID
account.margin_rate # 必要証拠金率
{% endhighlight %}

<div class="next">
  <a href="020400_getting_financial_and_economic_data.html">次のページへ: 各種金融・経済データを取得する</a>
</div>
