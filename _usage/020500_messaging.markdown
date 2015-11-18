---
layout: usage
title:  "Push通知・メールを送信する"
class_name: "messaging"
nav_class_name: "lv2"
---

エージェントから、Push通知やメールを送信することができます。以下のような使い方が可能です。

- エージェントでレートを監視し、急騰し始めたタイミングで、Push通知を送信。<br/>
  通知を受け取り、ユーザーが最終判断を行って、トレードする。(半自動型システムトレード)
- 取引を行ったタイミンクでメールや通知を送信し、トレードの状況をリアルタイムに把握。

また、Push通知にはアクションを指定することができます。<br/>
指定されたアクションは、通知一覧で「アクションボタン」として表示されます。

![通知一覧画面](/images/usage/messaging_01.png)

このボタンを押すことで、エージェントに任意のアクションを実行させることができます。

<div class="ad">
<h3>スマホアプリも、ぜひご利用ください!</h3>
スマホアプリなら、Push通知をリアルタイムに受信できます! インストールはこちらから。<br/>
→ <a  href="../install/040000_install_app.html">インストールガイド - スマホアプリのインストール</a>
</div>

<h3>Push通知を送る</h3>

Push通知を送るには、`notifier#push_notification(message, actions)` を実行します。

{% highlight ruby %}
# Push通知を送信
# 第一引数でメッセージ、第二引数でアクションを指定します。
notifier.push_notification('メッセージ')
notifier.push_notification('メッセージ',  [
  # アクションは複数指定できます。
  # 'label' が、アクションを実行するボタンのラベル、
  # 'action'が、ボタンが押されてアクションが実行されたとき、Agent#execute_action に渡される識別子になります。
  { 'label' => 'アクション1', 'action' => 'action_1' },
  { 'label' => 'アクション2', 'action' => 'action_2' }
])
{% endhighlight %}


<h3>メールを送信する</h3>

`notifier#compose_text_mail(to, title, body, from)` で、任意のアドレスにメールを送信できます。

{% highlight ruby %}
# メールを送信
# 最後の引数fromは省略可能です。省略された場合、'jiji@unageanu.net'が使用されます。
notifier.compose_text_mail('foo@example.com', 'テスト', 'テスト本文', 'jiji@unageanu.net')
{% endhighlight %}

<div class="warn">
<b>※メールを送信するには、SMTPサーバーの設定が必要です。</b><br/>
設定は、インストール後の初期設定、または、[設定] - [SMTPサーバーの設定] から行うことができます。
</div>


<div class="next">
  <a href="020600_action.html">次のページへ: アクションを実行できるようにする</a>
</div>
