---
layout: usage
title:  "エージェントの初期化と実行の流れ"
class_name: "initialization"
nav_class_name: "lv2"
---

エージェントの初期化と実行の流れを以下に示します。<br/>
バックテストを開始した場合や、エージェントをリアルトレードに登録した場合、以下の順番でエージェントのメソッドが呼び出されます。

![エージェントの初期化と実行の流れ](/images/usage/agent-lifecycle.png)

<p class="step">1. コンストラクタ ( <code>initialize()</code> )</p>
  - エージェントクラスのコンストラクタが実行され、インスタンスを生成します。

<div class="warn">
<b>※コンストラクタ内では、brokerやloggerといった依存コンポーネントは、利用できません。</b>
依存コンポーネントが必要な初期化処理は、 5. 初期化処理の実行(<code>post_create()</code>) で行ってください。
</div>

<p class="step">2. プロパティの設定 ( <code>properties=(properties)</code> )</p>
  - エージェントの登録画面で設定したプロパティを、エージェントに設定します。
  - プロパティは、「プロパティIDをキー、プロパティ値を値とするハッシュ」で渡されます。
  - デフォルトの実装は以下の通りで、各キーの値をエージェントのインスタンス変数に設定するようになっています。 オーバーライドして任意の処理を行うことも可能です。

{% highlight ruby %}
  def properties=( properties )
    @properties = properties
    properties.each_pair {|k,v|
      instance_variable_set("@#{k}", v)
    }
  end
{% endhighlight %}

<div class="notice">
  <b>※プロパティの値は文字列型で渡されます</b>。数値等への変換は、エージェントで行ってください。
</div>

<p class="step">3. 依存コンポーネントの設定( <code>broker=(broker), logger=(logger) ..etc..</code> )</p>
  - エージェントに依存コンポーネントを設定します。
    - <b>broker</b> .. 取引や決済など、証券会社へのアクセスを提供するコンポーネントです。
    - <b>graph_factory</b> .. エージェントでグラフを描画する際に使用します。
    - <b>notifier</b> .. メール、Push通知を送信するときに利用します。
    - <b>logger</b> .. デバッグ用のログを出力するときに使用します。

<p class="step">4. 初期化処理の実行 ( <code>post_create()</code> )</p>
  - プロパティ、依存コンポーネントの設定が終わったタイミングで、`post_create` が呼び出されます。
  - 初期化はコンストラクタで行うことも可能ですが、`post_create`であれば、loggerなどの依存コンポーネントを利用できます。

<p class="step">5. 状態の復元 ( <code>restore_state(state)</code> ) ※状態が保存されている場合のみ</p>
  - システムの再起動等で状態が保存されていた場合、`restore_state(state)` で状態の復元が行われます。
  - デフォルトの実装は空なので、必要に応じでオーバーライドして実装してください。

<p class="step">6. レート情報の処理 ( <code>next_tick(tick)</code> )</p>
  - 初期化が終わると、システムにより15秒ごとに `next_tick(tick)` が実行されます。
  - オーバーライドして、取引やPush通知を行うロジックを実装してください。
  - 引数でレート情報が渡されます。以下のようなコードで情報にアクセス可能です。

{% highlight ruby %}
  value = tick[:EURJPY]
  value.bid    # EURJPY の bidレート
  value.ask    # EURJPY の askレート

  value = tick[:USDJPY]
  value.bid    # USDJPY の bidレート
  value.ask    # USDJPY の askレート
{% endhighlight %}


<p class="step">7. (システムが停止された場合) 状態の読み出しと保存 ( <code>state()</code> )</p>
  - システムが停止された場合、`state` で状態の読み出しが行われます。
  - 返却された状態はシステムで保存され、次回システムを再起動した際に、`restore_state(state)` の引数として渡されます。
  - デフォルトの実装は、空のハッシュを返すようになっています。必要に応じてオーバーライドしてください。

<div class="warn">
※状態は、 <code>Mongoid#Hash</code> として永続化されます。<b>Hashに格納できない型を返却すると永続化に失敗します</b>のでご注意ください。
文字列や数値型であれば、問題ありません。
</div>

<br/>
各メソッドの詳細は[APIリファレンス](/rdocs)を参照ください。

<div class="next">
  <a href="020200_trading.html">次のページへ: 取引を行う</a>
</div>
