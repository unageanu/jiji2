---
layout: install
title:  "2. Jijiのインストール"
class_name: "install_to_server"
---

インストール方法を選択して、インストールを開始してください。

### 比較表

<table class="comparison no_indent">
  <tr>
    <th></th>
    <th>Herokuにインストール</th>
    <th>AWSにインストール</th>
    <th>Dockerにインストール</th>
  </tr>
  <tr>
    <td>導入の<br/>しやすさ</td>
    <td>
      <div class="rank very_good">◎</div>
      1クリックインストールが可能です
    </td>
    <td>
      <div class="rank">△</div>
      やや複雑
    </td>
    <td>
      <div class="rank">△</div>
      外部からのアクセスを許可する設定が追加で必要
    </td>
  </tr>
  <tr>
    <td>性能</td>
    <td>
      <div class="rank">△</div>
      MongoLabの無料プランを利用しているため、他より劣ります
    </td>
    <td>      
      <div class="rank good">〇</div>
      インスタンスタイプに依存
    </td>
    <td>
      <div class="rank good">〇</div>
      インストールするマシンの性能に依存
    </td>
  </tr>
  <tr>
    <td>コスト</td>
    <td>
      <div class="rank good">〇</div>
      月額$7～
    </td>
    <td>     
      <div class="rank very_good">◎</div>
      月額 $6.5 + データ転送料 ～<br/>
      無料利用枠を利用することも可
    </td>
    <td>      
      <div class="rank">-</div>
      自宅サーバーなら、電気代/通信費
    </td>
  </tr>
</table>

<div class="install_type">
  Herokuにインストール
</div>

- クラウドプラットフォームのHeroku上にインストールします。
- Herokuのアカウントが必要です。
- 24時間稼働させるには、<b>Hobby(月額$7)以上のプラン</b>を利用する必要があります。
- 動作速度は他と比べてやや劣ります。
   - MongoLabの無料プランを利用しているため。
   - 有料プランに変更することで性能を改善できる可能性はありますが、運用コストも上がります。

<div class="next">
  <a href="020100_install_server_to_heroku.html">Herokuにインストールする</a>
</div>

<div class="install_type">
  AWSにインストール
</div>

- [Amazon Web Service](https://aws.amazon.com/jp/) 上にインストールします。
- [Amazon Web Service](https://aws.amazon.com/jp/) のアカウントが必要です。
- 月額費用: <b>$6.5+データ転送量 ～</b>

<div class="next">
  <a href="020200_install_server_to_aws.html">AWSにインストールする</a>
</div>

<div class="install_type">
  Dockerにインストール
</div>

- LinuxなどにインストールされたDocker上にインストールします。
- Docker 1.9 以降, Docker Compose 1.5 以降 が必要です。
- 外出先やスマホアプリからアクセスするためには、ネットワーク設定が別途必要です。

<div class="next">
  <a href="020300_install_server_to_docker.html">Dockerにインストールする</a>
</div>
