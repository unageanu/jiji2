---
layout: install
title:  "2.1. Herokuにインストール"
class_name: "install_server_to_heroku"
nav_class_name: "lv2"
---

[Heroku](https://www.heroku.com/home) にJijiをインストールします。

<p class="step">1. Herokuのアカウントを作成し、ログインしてください。</p>
  - アカウントは[こちらから](https://signup.heroku.com/login)作成できます。
  - Add On を利用するため、クレジットカードを登録しておく必要があります。

<div class="warn">
※デフォルトでは、無料のプランおよび無料のAdd Onのみ使用するため、<b>請求は発生しません。</b>
ただし、24時間連続稼働させるためには、Hobby(月額$7)以上のプランに切り替える必要があります。
切り替えの手順は、このドキュメントの最後にご案内します。必要に応じて切り替えを行ってください。
</div>

<p class="step">2. Herokuにログインした状態で、以下のボタンをクリックしてください。</p>
<a id="install_server_to_heroku" href="https://heroku.com/deploy?template=https://github.com/unageanu/jiji2/tree/master" target="_blank">
  <img class="deploy_to_heroku" src="https://www.herokucdn.com/deploy/button.svg" />
</a>

→ デプロイ設定ページが表示されます。

<p class="step">3. デプロイ設定ページで、[App Name] を入力します。</p>
![手順1](/images/install/install_server_to_heroku_01.png)

<div class="notice no_indent">
※App NameはサーバーURLの一部になります。わかりやすい名前を設定しておくことをお勧めします。<br/>
※App Nameは省略可能です。省略すると、Herokuが自動で値を設定します。
</div>

<p class="step">4. 下にある [Deploy For Free] をクリックします。</p>
![手順2](/images/install/install_server_to_heroku_02.png)

→ デプロイが始まります。すこし時間がかかるので、お待ちください。

<p class="step">5. デプロイ完了後、[View] ボタンを押すと、Jijiにアクセスできます。</p>
![手順3](/images/install/install_server_to_heroku_03.png)

<p class="step">6. Hobbyプランに変更する (オプション)</p>
  - Jijiを24時間連続稼働させるためには、Hobby(月額$7)以上のプランに切り替える必要があります。必要に応じて切り替えを行ってください。
  - デフォルトでは Free プランになっています。
  - 各プラン(Dyno Type)の詳細は[こちら](https://devcenter.heroku.com/articles/dyno-types#available-dyno-types) を参照ください。

変更の手順は次の通りです。

1. [Manage App] をクリックします。
![手順4](/images/install/install_server_to_heroku_04.png)

2. 右上の [upgrade to Hobby] をクリック
![手順5](/images/install/install_server_to_heroku_05.png)

3. Dyno Type を [Hobby] に切り替えて [Save] をクリックします。
![手順6](/images/install/install_server_to_heroku_06.png)

<div class="next">
  <a href="030000_initial_setting.html">Jijiの初期設定に進む</a>
</div>


<script >
$( document ).ready(function() {
  $('#install_server_to_heroku').on('click', function() {
    ga('send', 'event', 'install', 'install_server_to_heroku');
  });
});
</script>
