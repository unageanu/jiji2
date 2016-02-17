---
layout: install
title:  "2.3. AWSにインストール"
class_name: "install_server_to_aws"
nav_class_name: "lv2"
---

[Amazon Web Service](https://aws.amazon.com/jp/) 上にJijiをインストールします。

- EC2インスタンス上のAmazon Linuxに、Dockerをインストールして、Jijiを実行する手順です。
  - AMIイメージは、Dockerをインストールできれば、他のAMIを利用することもできます。
  - Dockerへのインストール手順は、[Dockerにインストール](./020300_install_server_to_docker.html) も参照ください。
- 月額料金をなるべく安く済ませるため、もっともシンプルな構成にしています。CloudWatchでの死活監視など必要であれば、別途設定を行ってください。
- [Amazon Web Service](https://aws.amazon.com/jp/)のアカウントを用意していることを前提としているので、事前にご用意ください。

<p class="step">1. 使用するリージョンの選択</p>

はじめに、インスタンスを起動するリージョンを選択します。

- 任意のリージョンを使用できますが、リージョンによってインスタンスの利用料金や提供されている機能が異なるので注意が必要です。
  - 2016-02-16 時点では、最も安い t2.nano インスタンスは、「アジアパシフィック（東京）」より「米国東部 (バージニア北部)」の方が安く済みます。
- この手順の確認は「米国東部 (バージニア北部)」を利用して行っています。

1. [Amazon Web Service](https://aws.amazon.com/jp/) にログインして、機能一覧からEC2を選択します。

2. 右上のメニューから、リージョンを選択します。


<p class="step">2. キーペアの作成</p>

キーペアを作成します。
キーペアは、起動したEC2インスタンスにアクセスするときに使用します。

1. 「キーペア」を選択します。

2. 「キーペアの作成」をクリックして、任意の名前でキーペアを作成します。

3. プライベートキーがダウンロードされるので、保存しておきます。

<div class="warn">
ダウンロードしたプライベートキーファイルは、安全な場所に保存してください。
</div>


<p class="step">3. EC2インスタンスの作成と起動</p>

EC2インスタンスを作成して、起動します。

1. メニューから「インスタンス」をクリックします。


<div class="notice">
一定期間継続して稼働させる場合は、リザーブドインスタンスを使うことで、料金を抑えることができます。
詳しくは、<a href="https://aws.amazon.com/jp/ec2/purchasing-options/reserved-instances/" target="_blank">こちら</a>をご覧ください。
</div>


2. 「インスタンスの作成」をクリック

3. 「Amazon Linux AMI 2015.09.1 (HVM), SSD Volume Type」を選択します。

4. インスタンスタイプを選択して、「次の手順:インスタンスの詳細の設定」をクリックします。
  - 2016-02-16 時点で最も安い `t2.nano` を選択します。
  - 無料利用枠を利用する場合は、 `t2.micro` を選択してください。

5. デフォルトの設定のまま、「次の手順:ストレージの追加」をクリックします。

6. ディスクサイズを設定して、「次の手順:インスタンスのタグ付け」をクリックします。
  - OS領域に TODO GB、Jijiには保存するバックテストの数にもよりますが4GB程度あれば十分なので、12GBにします。
  - 必要に応じてカスタマイズしてください。ただし、サイズを増やすとその分利用料金も高くなります。
  - ディスクサイズは後で変更することもできます。

7. デフォルトの設定のまま、「次の手順:セキュリティグループの設定」をクリックします。

8. セキュリティグループを設定して、「確認と作成」をクリックします。
  - 「セキュリティグループの割り当て」で「新しいセキュリティグループを作成する」を選択します。
  - 「セキュリティグループ名」「説明」に任意の名前を設定します。
  - デフォルトで追加されている「SSH」レコードの「送信元」を自身のIPアドレスの範囲に変更します。
    - ドロップダウンから「マイ IP」を選択すると、アクセス元のIPアドレスが自動入力されます。
      アドレスが頻繁に更新されない場合はこれを利用するのが容易です。
  - 「ルールの追加」から、「HTTP」「HTTPS」を追加します。

9. 内容を確認して、「作成」をクリックします。


10. キーペアの選択ダイアログが表示されるので、2で作成したキーペアを選択し、「インスタンスの作成」をクリックします。


11. インスタンスの作成が開始されるので、しばらく待ちます。

<p class="step">4. Jijiのインストール</p>

EC2インスタンスにSSHでアクセスし、`Jiji`をインストールします。

1. 任意のSSHクライアントを起動し、ec2-user, 秘密鍵、で

2. ログインしたら、以下のコマンドを実行して

$ sudo yum update -y
$ docker -v
Docker version 1.9.1, build a34a1d5/1.9.1

3. Docker をインストールします。

sudo yum install -y docker
sudo service docker start
sudo chkconfig docker on
sudo usermod -a -G docker ec2-user

4. docker-composeのインストール

curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
sudo mv /tmp/docker-compose /usr/local/bin/
sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose -v
docker-compose version 1.6.0, build d99cad6


5. git のインストール

$ sudo yum install -y git
$ git --version
git version 2.4.3


6.　SWAP領域の追加 (t2.nanoのみ)

t2.nanoを利用している場合、Docker イメージのビルドや削除時にメモリが不足するため、以下の手順でSWAP領域を追加します。

$ sudo dd if=/dev/zero of=/swapfile1 bs=1M count=512
$ sudo chmod 600 /swapfile1
$ sudo mkswap /swapfile1
$ sudo swapon /swapfile1
$ sudo echo "/swapfile1  swap        swap    defaults        0   0" >> /etc/fstab

6. jijiのインストール


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
　 - Jijiのポート番号を443(SSLを利用しない場合は、80)に変更します。

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
    # 443 に変更します。
    - "443:443"
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
