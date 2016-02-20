---
layout: install
title:  "2.3. Dockerにインストール"
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

{% include install/install_to_docker.html section_no=2 %}
