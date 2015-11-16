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

<p class="step">2. プロパティの設定 ( <code>properties=(properties)</code> )</p>
  - エージェントの登録画面で設定したプロパティを、エージェントに設定します。

<p class="step">3. 依存コンポーネントの設定( <code>broker=(broker), logger=(logger) ..etc..</code> )</p>
  - エージェントに、依存コンポーネントを設定します。
    - <b>broker</b> .. 取引や決済など、証券会社へのアクセスを提供するコンポーネントです。
    - <b>graph_factory</b> .. エージェントでグラフを描画する際に使用します。
    - <b>notifier</b> .. メール、Push通知を送信するときに利用します。
    - <b>logger</b> .. デバッグ用のログを出力するときに使用します。

<p class="step">4. 状態の復元 ( <code>restore_state(state)</code> ) ※状態が保存されている場合のみ</p>
  - システムの再起動等で状態が保存されていた場合、`restore_state(state)` で状態の復元が行われます。

<p class="step">5. 初期化処理の実行 ( <code>post_create()</code> )</p>
  - プロパティ、依存コンポーネントの設定が終わったタイミンクで、`post_create` が呼び出されます。
  - プロパティ、依存コンポーネントに依存する初期化処理を実行します。

<p class="step">6. レート情報の処理 ( <code>next_tick(tick)</code> )</p>
  - システムにより定期的に呼び出されます。
  - 引数で渡されるレート情報をもとに、取引やPush通知などの処理を行います。

<p class="step">7. (システムが停止された場合) 状態の読み出しと保存 ( <code>state()</code> )</p>
  - システムが停止された場合、`state` でエージェントの状態の読み出しが行われます。
  - 返却された状態はシステムで保存され、次回システムを再起動した際に、`restore_state(state)` の引数として渡されます。

<br/>
各メソッドの詳細は[APIリファレンス](/TODO)を参照ください。

<div class="next">
  <a href="020200_trading.html">次のページへ: 取引を行う</a>
</div>
