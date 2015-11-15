---
layout: usage
title:  "自動取引の流れ"
class_name: "basic_flow"
---

Jijiでの自動取引の流れは次の通りです。<br/>
このドキュメントでは、↓の流れに従って、各画面の使い方を説明していきます。

<div class="section">
  <a href="/usage/010100_create_agent.html">1. 取引アルゴリズム(エージェント)の作成</a>
</div>

  - [エージェント] から取り引きアルゴリズム(エージェント)をRubyで作成します。

<div class="section">
  <a href="/usage/010200_create_backtest.html">2. バックテスト</a>
</div>

  - [バックテスト - テストの作成]から、バックテストを作成・実行し、エージェントの動作を確認します。
  - 1つのバックテストで、複数のエージェントを同時にテストすることが可能です。

<div class="section">
  <a href="/usage/010300_analyze_backtest_result.html">3. テスト結果の確認</a>
</div>

  - テストの実行完了後、[バックテスト - テスト一覧]から取引の結果を確認。
  - 満足できる結果が得られれば運用を開始します。そうでなければ1に戻ってエージェントのアルゴリズムを見直します。

<div class="section">
  <a href="/usage/010400_start_real_trade.html">4. リアル口座で実行</a>
</div>

  - [リアルトレード - エージェント設定]でエージェントを登録し、リアル口座(OANADAの個人口座 or デモ口座)で実行を開始します。

<div class="section">
  <a href="/usage/010500_analyze_trading.html">5. 取引状況の確認</a>
</div>

  - [リアルトレード - 取引状況] で勝率やProfit Factorなど取引の状況を把握できます。
  - エージェントからの通知は、[通知一覧]で見ることができます。



<div class="next">
  <a href="010100_create_agent.html">次のページへ: 1.取引アルゴリズム(エージェント)の作成</a>
</div>
