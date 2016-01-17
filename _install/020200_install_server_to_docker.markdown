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

<p class="step">3. ポート番号の変更が必要な場合、docker-compose.yml を編集します。</p>
  - デフォルトでは、Jijiがポート8080、mongodbがポート27017 を使用します。
  - 例えば、Jijiのポートを80にする場合、docker-compose.ymlの内容を以下の通り変更します。

{% highlight yaml %}
jiji:
  container_name: jiji_jiji
  build: ./build/jiji
  links:
    - mongodb
  ports:
    - "80:8080"

mongodb:
  container_name: jiji_mongodb
  image: mongo:3.0.7
  ports:
    - "27017:27017"
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
{% endhighlight %}

以下のコマンドで、起動しているコンテナを確認できます。

{% highlight sh %}
$ sudo docker ps -a
{% endhighlight %}

起動していれば、以下のURLでJijiにアクセスできます。
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
{% endhighlight %}
