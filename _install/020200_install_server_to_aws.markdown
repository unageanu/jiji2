---
layout: install
title:  "2.3. AWSにインストール"
class_name: "install_server_to_aws"
nav_class_name: "lv2"
---

[Amazon Web Service](https://aws.amazon.com/jp/) 上にJijiをインストールします。

- EC2インスタンス上のAmazon Linuxに、Dockerをインストールして、その上でJijiを実行します。
  - Dockerをインストールできれば他のAMIイメージを利用することもできます。
- 月額料金をなるべく安く済ませるため、もっともシンプルな構成にしています。
  - 月額: $6.5 + データ転送料 ～
  - CloudWatchでの死活監視など必要であれば、別途設定を行ってください。
- [Amazon Web Service](https://aws.amazon.com/jp/)のアカウントを用意していることを前提としているので、事前にご用意ください。

<p class="step">1. EC2のコンソールを開きます。</p>

[Amazon Web Service](https://aws.amazon.com/jp/) にログインして、機能一覧からEC2を選択してください。
![画面](/images/install/aws_01.png)

<p class="step">2. 使用するリージョンを選択します。</p>

右上のメニューから、リージョンを選択します。

- 任意のリージョンを使用できますが、リージョンによってインスタンスの利用料金や提供されている機能が異なるので注意が必要です。
  - 2016-02-16 時点では、最も安い t2.nano インスタンスは、「アジアパシフィック（東京）」より「米国東部 (バージニア北部)」の方が安く済みます。
- この手順の確認は「米国東部 (バージニア北部)」を利用して行っています。

![画面](/images/install/aws_02.png)

<p class="step">3. キーペアを作成します。</p>

キーペアは、起動したEC2インスタンスにアクセスするときに使用します。

1. 「キーペア」を選択します。
   ![画面](/images/install/aws_03.png)

2. 「キーペアの作成」をクリックして、任意の名前でキーペアを作成します。
   ![画面](/images/install/aws_04.png)

3. プライベートキーがダウンロードされるので、保存しておきます。
   <div class="warn no_indent">
   ダウンロードしたプライベートキーファイルは、安全な場所に保存してください。
   </div>


<p class="step">4. EC2インスタンスを作成して起動します。</p>

1. メニューから「インスタンス」をクリックします。
   ![画面](/images/install/aws_05.png)
   <div class="notice no_indent">
   一定期間継続して稼働させる場合は、リザーブドインスタンスを使うことで、料金を抑えることができます。
   詳しくは、<a href="https://aws.amazon.com/jp/ec2/purchasing-options/reserved-instances/" target="_blank">こちら</a>をご覧ください。
   </div>

2. 「インスタンスの作成」をクリック
   ![画面](/images/install/aws_06.png)

3. 「Amazon Linux AMI 2015.09.1 (HVM), SSD Volume Type」を選択します。
   ![画面](/images/install/aws_07.png)

4. インスタンスタイプを選択して、「次の手順:インスタンスの詳細の設定」をクリックします。
  - 2016-02-16 時点で最も安い `t2.nano` を選択します。
  - 無料利用枠を利用する場合は、 `t2.micro` を選択してください。

   ![画面](/images/install/aws_08.png)
   <div class="notice no_indent">
   <code>t2.nano</code> を利用する場合、Dockerコンテナのビルドや削除を行うと、メモリ不足でフリーズする場合があります。
   このような場合は、一時的にインスタンスタイプを <code>t2.nano</code> にして操作を実行してください。
   システムの実行は <code>t2.nano</code> で問題ありません。
   </div>

5. デフォルトの設定のまま、「次の手順:ストレージの追加」をクリックします。
   ![画面](/images/install/aws_09.png)

6. ディスクサイズを設定して、「次の手順:インスタンスのタグ付け」をクリックします。
  - OS領域に8GB、Jijiには保存するバックテストの数にもよりますが4GB程度あれば十分なので、12GB確保すれば問題ありません。
  - 必要に応じてカスタマイズしてください。ただし、サイズを増やすとその分利用料金も高くなります。
  - ディスクサイズは後で変更することもできます。

   ![画面](/images/install/aws_10.png)

7. デフォルトの設定のまま、「次の手順:セキュリティグループの設定」をクリックします。
   ![画面](/images/install/aws_11.png)


8. セキュリティグループを設定して、「確認と作成」をクリックします。
  - 「セキュリティグループの割り当て」で「新しいセキュリティグループを作成する」を選択します。
  - 「セキュリティグループ名」「説明」に任意の名前を設定します。
  - デフォルトで追加されている「SSH」レコードの「送信元」を自身のIPアドレスの範囲に変更します。
  - 「ルールの追加」から、「HTTP」「HTTPS」を追加します。

   ![画面](/images/install/aws_12.png)

9. 内容を確認して、「作成」をクリックします。
   ![画面](/images/install/aws_13.png)

10. キーペアの選択ダイアログが表示されるので、2で作成したキーペアを選択し、「インスタンスの作成」をクリックします。
   ![画面](/images/install/aws_14.png)

11. インスタンスの作成が開始されるので、しばらくお待ちください。

<p class="step">5. EC2インスタンスにログインします。</p>

1. インスタンスが起動したら、詳細画面からパブリックIPアドレスを取得します。
   ![画面](/images/install/aws_15.png)

2. 任意のSSHクライアントを起動し、以下を指定してインスタンスにログインします。

   - IPアドレス: ↑で取得したパブリックIPアドレス
   - ポート番号: 22
   - ユーザー名: ec2-user
   - キーファイル: 2でダウンロードした秘密鍵を指定
    <div class="notice no_indent">
    ※詳しい手順は<a href="http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html" target="_blank">こちら</a>をご覧ください。
    </div>

<p class="step">6. Docker, Gitをインストールします。</p>

以下のコマンドを実行して、必要なモジュールをインストールします。

{% highlight sh %}
# システムをアップデート
$ sudo yum update -y

# Dockerをインストール
$ sudo yum install -y docker
$ docker -v
Docker version 1.9.1, build a34a1d5/1.9.1
$ sudo service docker start
$ sudo chkconfig docker on
$ sudo usermod -a -G docker ec2-user

# docker-composeをインストール
$ curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
$ sudo mv /tmp/docker-compose /usr/local/bin/
$ sudo chmod +x /usr/local/bin/docker-compose
$ /usr/local/bin/docker-compose -v
docker-compose version 1.6.0, build d99cad6

# git をインストール
$ sudo yum install -y git
$ git --version
git version 2.4.3
{% endhighlight %}

{% include install/install_to_docker.html section_no=7 nginx_port=443 %}
