---
layout: install
title:  "2.2. Dockerにインストール"
class_name: "install_server_to_docker"
nav_class_name: "lv2"
---

[Docker](https://www.docker.com/) 上にJijiをインストールします。


<p class="step">1. 必要なソフトウェアをインストールします</p>
以下のソフトウェアが必要です。

  - Git
  - Docker .. 1.9以降
  - Docker Compose .. 1.5以降

{% highlight sh %}
$ git --version
git version 1.8.3.1
$ sudo docker --version
Docker version 1.9.0, build 76d6bc9
$ sudo docker-compose --version
docker-compose version: 1.5.0
{% endhighlight %}

<div class="notice">
※動作確認はCentOS 7上で行っています。以下のコマンドもCentOS 7を前提にしていますので、他の環境の場合は適宜読み替えてください。
</div>

<p class="step">2. Dockerfile をチェックアウトします。</p>
{% highlight sh %}
$ git clone https://github.com/unageanu/docker-jiji2
$ cd docker-jiji2
{% endhighlight %}

<p class="step">3. SSL証明書を用意します。</p>

- ドメインを所有している場合は、[Let's Encrypt](https://letsencrypt.org/)を利用して、無料でSSL証明書を取得できます。
   - 取得方法は[こちら](https://letsencrypt.jp/usage/)をご覧ください。<br/><br/>
- ローカルで作成した自己署名証明書を使用することもできます。
   - 自己署名証明書を使用した場合、通信の暗号化はできますがサーバー認証はできません。
     ブラウザおよびアプリで警告が表示されますので、ご了承ください。
   - 自己責任でのご利用をお願いします。<br/><br/>
- SSLを利用しない場合は、 <code>docker-compose-without-ssl.yml</code> をご使用ください。
   - SSLプロキシとして使用している `Nginx` なしの構成でセットアップします。
   - `docker-compose-without-ssl.yml` を `docker-compose.yml` にリネームして使用するか、
     `-f` オプションで `docker-compose-without-ssl.yml` を明示してください。
   - 通信の暗号化は行われませんので、自己責任でのご利用をお願いします。

自己署名証明書を生成する例:
{% highlight sh %}
# 秘密鍵を生成
$ openssl genrsa 2048 > server.key
# CSRを作成
$ openssl req -new -key server.key > server.csr
# サーバー証明書を作成
$ openssl x509 -sha256 -days 365 -req -signkey server.key < server.csr > server.crt
{% endhighlight %}

<p class="step">3. docker-compose.yml を編集します。</p>

以下の項目を設定します。

- <b>SSL証明書のパス</b>
   - 3 で用意したSSL証明書の公開鍵と秘密鍵のパスを設定します。
   - `./path/to/ssl.key` のように `./` で始めることで、 `docker-compose.yml` からの相対パスで指定できます。
- <b>MongoDBデータの保存先</b>
   - デフォルトでは、MongoDBコンテナ内に作成されます。
   - ホストマシンの任意の場所に保存したい場合は、 `volumes` のコメントを解除して、保存先のパスを設定します。
- <b>ポート番号</b>
   - デフォルトでは、Jijiがポート8443、mongodbがポート27018 を使用します。(SSLを使用しない場合、Jijiは8080を使用します)
   - 必要に応じてカスタマイズしてください。

以下は設定例です。

{% highlight yaml %}
jiji:
  container_name: jiji_jiji
  build: ./build/jiji
  links:
    - mongodb

mongodb:
  container_name: jiji_mongodb
  image: mongo:3.0.7
  ports:
    # MongoDBのポート番号
    # 必要に応じて変更してください。
    - "27018:27017"
  volumes:
    # MongoDBのデータを保存するディレクトリ
    # デフォルトでは、コンテナ内に作成します。(この場合、コンテナを再作成すると、データが初期化されます)
    # コメントアウトしてパスを設定することで、ホストマシンの任意のディレクトリに変更することができます。
    # './' で始めることで、docker-compose.ymlからの相対パスで指定可能です。
    - ./path/to/data/dir:/data/db

nginx:
  container_name: jiji_nginx
  build: ./build/nginx
  links:
    - jiji
  ports:
    # Jijiのポート番号
    # 必要に応じて変更してください。
    - "8443:443"
  volumes:
    # SSL証明書のパス
    # './path/to/server.crt' にサーバー証明書、
    # './path/to/server.key' に秘密鍵を指定します。
    # './' で始めることで、docker-compose.ymlからの相対パスで指定可能です。
    - ./path/to/server.crt:/etc/nginx/cert/ssl.crt:ro
    - ./path/to/server.key:/etc/nginx/cert/ssl.key:ro
{% endhighlight %}

<p class="step">3. Docker イメージをビルドします</p>

{% highlight sh %}
$ sudo docker-compose build
{% endhighlight %}

<div class="notice">
ビルドには時間がかかるので、あらかじめご了承ください。
</div>

<p class="step">4. Dockerコンテナを作成し、起動します。</p>

{% highlight sh %}
$ sudo docker-compose up -d
Creating jiji_mongodb
Creating jiji_jiji
Creating jiji_nginx
{% endhighlight %}

以下のコマンドで、起動しているコンテナを確認できます。

{% highlight sh %}
$ sudo docker ps -a
{% endhighlight %}

起動していれば、以下のURLでJijiにアクセスできます。
{% highlight sh %}
https://<インストール先ホスト>:<docker-compose.ymlで設定したJijiのポート/デフォルトは8443>
{% endhighlight %}

SSLを利用しない場合は以下のURLになります。

{% highlight sh %}
http://<インストール先ホスト>:<docker-compose.ymlで設定したJijiのポート/デフォルトは8080>
{% endhighlight %}

<br/>

<div class="warn no_indent">
※Jijiが動作しない場合、起動ログを確認してください。起動ログは、以下のコマンドで確認できます。
<br/><br/>
{% highlight sh %}
$ sudo docker start -a jiji_jiji
{% endhighlight %}

</div>

<div class="next">
  <a href="030000_initial_setting.html">Jijiの初期設定に進む</a>
</div>


## 補足1: コンテナを停止・再起動する

Jijiを停止するには以下のコマンドを実行します。

{% highlight sh %}
$ sudo docker-compose stop
{% endhighlight %}

停止したコンテナを再起動するには、start コマンドを実行します。

{% highlight sh %}
$ sudo docker-compose start
{% endhighlight %}

<br/><br/>

## 補足2: サービスのログを確認する

logsコマンドでコンテナのログを確認できます。

{% highlight sh %}
$ sudo docker logs jiji_jiji
$ sudo docker logs jiji_mongodb
$ sudo docker logs jiji_nginx
{% endhighlight %}
