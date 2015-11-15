---
layout: usage
title:  "1. 取引アルゴリズム(エージェント)の作成"
class_name: "create_agent"
nav_class_name: "lv2"
---

Jijiでは、「取引アルゴリズム」を「エージェント」と呼びます。
エージェントは、レート情報を受け取って取引を行うRubyのクラスで、メニューの [エージェント] から作成できます。

※エージェントの詳しい書き方については、[エージェント作成ガイド](/usage/020000_create_agent.html) を参照ください。


エージェント編集画面の使い方は以下の通りです。

![エージェント編集画面](/images/usage/usage_01.png)

<div class="item">①エージェント一覧</div>
  - 作成済みのエージェントの一覧です。

<div class="item">②ファイル追加ボタン</div>
  - 新しいエージェントファイルを追加します。

<div class="item">③保存ボタン</div>
  - 編集したコードを保存します。コードに問題があった場合は、[メッセージ領域]にエラーの詳細が表示されます。

<div class="item">④削除ボタン</div>
  - 選択したファイルを削除します。

<div class="item">⑤メッセージ領域</div>
  - 保存したコードに問題があった場合に、エラーの詳細がここに表示されます。

<div class="item">⑥エージェントエディタ</div>
  - 選択したエージェントのRubyコードを編集するエディタ領域です。
  - Ctrl + F で検索、Ctrl + S で保存ができます。


<div class="next">
  <a href="010200_create_backtest.html">次のページへ: 2.バックテスト</a>
</div>
