---
layout: install
title:  "1. 証券口座の準備"
---

<p>Jijiを利用するには、OANDA Japan の口座 (無料デモ口座でもOKです) が必要です。<br/>
以下のバナーからOANADA Japan のサイトにアクセスして、口座を作成してください。</p>

<div class="link_to_oanda">
<a class="link_to_oanda" href="https://click.j-a-net.jp/1578403/517576/" target="_blank">
→ OANADA Japan のサイトへ
</a>
<a class="link_to_oanda large" href="https://click.j-a-net.jp/1578403/517576/" target="_blank">
  <img src="https://image.j-a-net.jp/1578403/517576/" width="728" height="90"  border="0" />
</a>
<a class="link_to_oanda small" href="https://click.j-a-net.jp/1578403/518058/" target="_blank">
  <img src="https://image.j-a-net.jp/1578403/518058/" width="234" height="60"  border="0" />
</a>
</div>
<div class="notice no_indent">
※アフィリエイトリンクになっています。<br/>サービス改善のため、よろしければご協力いただけると助かります!
</div>

<br/>

口座開設後、以下の手順でパーソナルアクセストークンを発行してください。

1. OANDA Japanの口座にログインしてください。

2. 右下の [APIアクセス管理] をクリック
![手順1](/images/install/prepare_securities_01.png)

3. [REST APIの管理] をクリック
![手順2](/images/install/prepare_securities_02.png)

4. API契約をご確認の上、パーソナルアクセストークンを発行してください。
![手順3](/images/install/prepare_securities_03.png)

5. 発行されたパーソナルアクセストークンをコピーしておきます。(あとでJijiに設定します。)

<div class="notice no_indent">
※個人口座の場合、OANDA FX REST APIを利用するためには、口座残高が25万円以上必要です。
  詳しくは<a href="http://www.oanda.jp/api/" target="_blank">こちら</a>をご覧ください。(無料デモ口座の場合、残高の制限はありません。)
</div>

<div class="next">
  <a href="020000_install_server.html">次へ</a>
</div>


<script >
$( document ).ready(function() {
  $('a.link_to_oanda').on('click', function() {
    ga('send', 'event', 'install', 'create_oanda_account');
  });
});
</script>
