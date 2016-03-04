---
layout: usage
title:  "デバッグログを出力する"
class_name: "logging"
nav_class_name: "lv2"
---

`logger` を使って、デバッグ用のログを出力することができます。

{% highlight ruby %}
# ログを出力。
logger.debug "test"
logger.info "info"
logger.warn "warn"
{% endhighlight %}

loggerのAPIについては、[Ruby リファレンスマニュアル - Logger](http://docs.ruby-lang.org/ja/2.2.0/library/logger.html)を参照下さい。<br/>
出力したログは、[バックテスト - テスト一覧 - ログ]、[リアルトレード - ログ]から確認できます。
↑のサンプルであれば以下のログが出力されます。

<pre>
D, [2015-11-18T07:26:31.612000 #7696] DEBUG -- : test
I, [2015-11-18T07:26:31.617000 #7696]  INFO -- : info
W, [2015-11-18T07:26:31.622000 #7696]  WARN -- : warn
</pre>

<div class="next">
  <a href="020900_customizing.html">次のページへ: エージェントのカスタマイズ</a>
</div>
